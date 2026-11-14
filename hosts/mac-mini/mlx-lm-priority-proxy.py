#!/usr/bin/env python3
"""On-demand priority proxy for mlx_lm.server.

Listens on 8080 (the port Hermes chat and crons target) and forwards to
mlx_lm.server on 8083, which THIS PROCESS owns: spawned on the first real
request, terminated after MLX_LM_IDLE_SECONDS without traffic, so the 9B
weights (~5.5 GB) only occupy memory while local models are in use.

GET /v1/models is answered statically and never triggers a load, so health
probes and model discovery stay free.

Pause flag (~/.local/state/local-models.paused): chat requests get a fast
503, /v1/models still answers, and a running backend is unloaded within one
watchdog cycle. Same flag the sketchybar toggle and scripts/local-models use.

Priority hold (inert, kept for safety): requests carrying the background API
key (Hindsight's old retain role) wait while priority traffic is in flight.

Recovery: an OOM-killed generation thread logs a known fatal line; a log
tailer kills the backend, so the next request respawns a healthy one. The
idle timer covers the rest — a wedged backend with no traffic unloads by
itself, which is what the old launchd watchdog used to do by restarting.
Pure Python stdlib; streaming (SSE) is relayed chunk by chunk.
"""
import json
import os
import socket
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

UPSTREAM_HOST = "127.0.0.1"
UPSTREAM_PORT = int(os.environ.get("MLX_LM_PORT", "8083"))
LISTEN_PORT = int(os.environ.get("MLX_LM_LISTEN_PORT", "8080"))
BACKGROUND_KEY = "hindsight-retain"
UPSTREAM_TIMEOUT = 1800  # mlx_lm prefills of ~64k can take a while
PAUSE_FLAG = os.path.expanduser("~/.local/state/local-models.paused")
MODEL_ID = os.environ.get("MLX_LM_MODEL", "mlx-community/Qwen3.5-9B-4bit")

# On-demand backend
IDLE_SECONDS = int(os.environ.get("MLX_LM_IDLE_SECONDS", "30"))
STARTUP_TIMEOUT = int(os.environ.get("MLX_LM_STARTUP_TIMEOUT", "180"))
BACKEND_BIN = os.path.expanduser(
    os.environ.get("MLX_LM_BIN", "~/.local/bin/mlx_lm.server")
)
LOG_PATH = os.path.expanduser(
    os.environ.get("MLX_LM_LOG", "~/Library/Logs/mlx-lm/server.log")
)
BACKEND_ARGS = [
    "--model", MODEL_ID,
    "--host", UPSTREAM_HOST,
    "--port", str(UPSTREAM_PORT),
    "--prompt-cache-bytes", os.environ.get("MLX_LM_PROMPT_CACHE_BYTES", "1610612736"),
    "--kv-bits", os.environ.get("MLX_LM_KV_BITS", "8"),
]
FATAL_LOG_LINES = (
    "generation thread died",
    "Insufficient Memory",
    "Command buffer execution failed",
)

lock = threading.Condition()
priority_inflight = 0
priority_waiting = 0

backend_lock = threading.Lock()
backend = None  # subprocess.Popen | None
last_activity = time.monotonic()


def log(msg):
    print(f"{time.strftime('%Y-%m-%d %H:%M:%S')} [proxy] {msg}", flush=True)


def is_background(headers):
    auth = headers.get("Authorization", "") or headers.get("authorization", "")
    return BACKGROUND_KEY in auth


def port_open(port, timeout=0.5):
    try:
        with socket.create_connection((UPSTREAM_HOST, port), timeout=timeout):
            return True
    except OSError:
        return False


def orphan_pid():
    """PID of a backend this process did not spawn (previous proxy run)."""
    try:
        out = subprocess.run(
            ["/usr/bin/pgrep", "-f", f"{BACKEND_BIN} --model"],
            capture_output=True, text=True, timeout=5,
        )
        pids = out.stdout.split()
        return int(pids[0]) if pids else None
    except (OSError, ValueError, subprocess.SubprocessError):
        return None


def stop_backend(reason):
    """SIGTERM, 10s grace, SIGKILL. Safe when the child is already gone."""
    global backend
    with backend_lock:
        proc = backend
        pid = proc.pid if proc is not None and proc.poll() is None else orphan_pid()
        if pid is None:
            backend = None
            return
        log(f"stopping backend pid {pid} ({reason})")
        try:
            os.kill(pid, 15)
        except ProcessLookupError:
            pass
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline:
            if proc is not None:
                if proc.poll() is not None:
                    break
            elif not port_open(UPSTREAM_PORT):
                break
            time.sleep(0.5)
        else:
            log(f"backend pid {pid} ignored SIGTERM, sending SIGKILL")
            try:
                os.kill(pid, 9)
            except ProcessLookupError:
                pass
        if proc is not None:
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                pass
        backend = None


def ensure_backend():
    """Start the backend if needed and wait until it answers. True = ready."""
    global backend
    if port_open(UPSTREAM_PORT):
        return True
    with backend_lock:
        if port_open(UPSTREAM_PORT):  # another thread won the race
            return True
        if backend is not None and backend.poll() is not None:
            backend = None
        if backend is None:
            os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
            with open(LOG_PATH, "ab", buffering=0) as log_file:
                log(f"starting backend: {BACKEND_BIN} {' '.join(BACKEND_ARGS)}")
                try:
                    backend = subprocess.Popen(
                        [BACKEND_BIN, *BACKEND_ARGS],
                        stdout=log_file, stderr=subprocess.STDOUT,
                        stdin=subprocess.DEVNULL, start_new_session=True,
                    )
                except OSError as e:
                    log(f"backend spawn failed: {e}")
                    return False
        deadline = time.monotonic() + STARTUP_TIMEOUT
        while time.monotonic() < deadline:
            if port_open(UPSTREAM_PORT):
                log("backend ready")
                return True
            if backend.poll() is not None:
                log(f"backend exited during startup (code {backend.returncode})")
                backend = None
                return False
            time.sleep(0.5)
        log(f"backend not ready after {STARTUP_TIMEOUT}s, giving up")
        return False


def watchdog():
    """Unload on pause or idle, so weights sit on the GPU only when in use."""
    while True:
        time.sleep(5)
        try:
            if os.path.exists(PAUSE_FLAG):
                if port_open(UPSTREAM_PORT):
                    stop_backend("pause flag")
                continue
            idle_for = time.monotonic() - last_activity
            if idle_for > IDLE_SECONDS and port_open(UPSTREAM_PORT):
                with lock:
                    busy = priority_inflight > 0
                if not busy:
                    stop_backend(f"idle {int(idle_for)}s")
        except Exception as e:  # the watchdog must never die
            log(f"watchdog error: {e}")


def log_tailer():
    """Kill a backend whose generation thread died (Metal OOM); the next
    request respawns it. Same fatal lines the old launchd supervisor used."""
    while True:
        try:
            with open(LOG_PATH, "rb") as f:
                f.seek(0, os.SEEK_END)
                while True:
                    line = f.readline()
                    if not line:
                        time.sleep(1)
                        continue
                    text = line.decode("utf-8", "replace")
                    if any(marker in text for marker in FATAL_LOG_LINES):
                        log(f"fatal backend log line: {text.strip()[:160]}")
                        stop_backend("fatal log line")
        except FileNotFoundError:
            time.sleep(5)
        except Exception as e:
            log(f"log tailer error: {e}")
            time.sleep(5)


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        pass

    def _relay(self):
        global priority_inflight, last_activity
        if os.path.exists(PAUSE_FLAG):
            if self.path.rstrip("/").endswith("/models"):
                return self._send_json(
                    200,
                    {
                        "object": "list",
                        "data": [{"id": MODEL_ID, "object": "model", "owned_by": "local"}],
                    },
                )
            return self._send_json(
                503,
                {
                    "error": {
                        "message": "local models paused (resume with ~/scripts/local-models resume)",
                        "type": "local_models_paused",
                        "code": 503,
                    }
                },
            )

        # Model discovery and health probes never cold-start the backend.
        if self.command == "GET" and self.path.split("?")[0].rstrip("/") == "/v1/models":
            return self._send_json(
                200,
                {
                    "object": "list",
                    "data": [{"id": MODEL_ID, "object": "model", "owned_by": "local"}],
                },
            )

        last_activity = time.monotonic()
        background = is_background(self.headers)

        if background:
            with lock:
                while priority_inflight > 0 or priority_waiting > 0:
                    lock.wait()
        with lock:
            priority_inflight += 1
        try:
            if not ensure_backend():
                return self.send_error(503, "local model failed to start")
            self._forward()
        finally:
            with lock:
                priority_inflight -= 1
                last_activity = time.monotonic()
                lock.notify_all()

    def _send_json(self, status, payload):
        # Explicit Content-Length + buffered body: pass-through framing of
        # any kind hangs keep-alive clients (learned on the vision proxy).
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def _forward(self):
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length) if length else 0

        req_lines = [f"{self.command} {self.path} HTTP/1.1"]
        for key, value in self.headers.items():
            if key.lower() in ("connection", "transfer-encoding", "accept-encoding"):
                continue
            req_lines.append(f"{key}: {value}")
        req_lines.append("Connection: close")
        req = ("\r\n".join(req_lines) + "\r\n\r\n").encode("latin-1")

        try:
            upstream = socket.create_connection(
                (UPSTREAM_HOST, UPSTREAM_PORT), timeout=UPSTREAM_TIMEOUT
            )
        except OSError:
            self.send_error(502, "mlx-lm upstream unavailable")
            return

        try:
            upstream.sendall(req)
            if body:
                upstream.sendall(body)

            self._pump(upstream)
        finally:
            upstream.close()

    def _pump(self, upstream):
        # Read the upstream response head, then stream the body through.
        upstream_file = upstream.makefile("rb")
        status_line = upstream_file.readline(65536)
        if not status_line:
            self.send_error(502, "empty upstream response")
            return
        headers = []
        content_length = None
        while True:
            line = upstream_file.readline(65536)
            if line in (b"\r\n", b"\n", b""):
                break
            name, _, value = line.decode("latin-1").partition(":")
            name_l = name.strip().lower()
            if name_l in ("connection", "transfer-encoding", "keep-alive"):
                continue
            if name_l == "content-length":
                content_length = int(value.strip())
            headers.append((name.strip(), value.strip()))

        try:
            self.send_response_only(int(status_line.split()[1]))
            self.send_header("Connection", "close")
            for name, value in headers:
                self.send_header(name, value)
            self.end_headers()

            self.wfile.flush()
            sent = 0
            while content_length is None or sent < content_length:
                chunk = upstream_file.read1(65536)
                if not chunk:
                    break
                self.wfile.write(chunk)
                self.wfile.flush()
                sent += len(chunk)
        except (BrokenPipeError, ConnectionResetError):
            pass

    do_GET = _relay
    do_POST = _relay
    do_DELETE = _relay
    do_PUT = _relay
    do_PATCH = _relay


class Server(ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = True


if __name__ == "__main__":
    threading.Thread(target=watchdog, daemon=True).start()
    threading.Thread(target=log_tailer, daemon=True).start()
    log(
        f"listening on {UPSTREAM_HOST}:{LISTEN_PORT} -> on-demand {MODEL_ID} "
        f"on :{UPSTREAM_PORT} (idle unload {IDLE_SECONDS}s)"
    )
    Server((UPSTREAM_HOST, LISTEN_PORT), Handler).serve_forever()

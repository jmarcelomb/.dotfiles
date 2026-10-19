#!/usr/bin/env python3
"""On-demand vision proxy for mlx_vlm.server.

Listens on 127.0.0.1:8081 and forwards requests to a lazily-started
mlx_vlm.server on 127.0.0.1:8082 (small VLM). The backend loads on the
first request and is unloaded after IDLE_SECONDS without traffic, so its
weights only occupy memory while vision is actually in use.

Stdlib only; run under /usr/bin/python3 via launchd (mlx-vision-ondemand.nix).
"""

import http.client
import http.server
import json
import os
import signal
import socket
import subprocess
import threading
import time

# --- tunables -----------------------------------------------------------
LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 8081
BACKEND_HOST = "127.0.0.1"
BACKEND_PORT = 8082
BACKEND_BIN = os.path.expanduser("~/.local/bin/mlx_vlm.server")
BACKEND_MODEL = "mlx-community/Qwen3.5-4B-4bit"
BACKEND_START_TIMEOUT = 300  # cold model load can take minutes on first pull
IDLE_SECONDS = int(os.environ.get("MLX_VISION_IDLE_SECONDS", "600"))
# The 9B text server (5.5 GB weights + KV) plus this 4B VLM sit near the
# ~10.5 GB wired GPU cap; a vision request can Metal-OOM while the text
# server holds a large prompt cache, then succeed once pressure eases.
# Retry 5xx responses before giving up.
RETRIES = int(os.environ.get("MLX_VISION_RETRIES", "2"))
RETRY_DELAY = 5
LOG_DIR = os.path.expanduser("~/Library/Logs/mlx-vision")
# ------------------------------------------------------------------------

_state_lock = threading.Lock()
_backend_proc = None
_last_used = time.time()
_inflight = 0


def _log(msg):
    line = f"{time.strftime('%Y-%m-%d %H:%M:%S')} {msg}\n"
    try:
        os.makedirs(LOG_DIR, exist_ok=True)
        with open(os.path.join(LOG_DIR, "proxy.log"), "a") as f:
            f.write(line)
    except OSError:
        pass


def _touch():
    global _last_used
    _last_used = time.time()


def _backend_port_open():
    try:
        with socket.create_connection((BACKEND_HOST, BACKEND_PORT), timeout=2):
            return True
    except OSError:
        return False


def _backend_ours():
    """True if the backend process is one we spawned (still running)."""
    return _backend_proc is not None and _backend_proc.poll() is None


def ensure_backend():
    """Start mlx_vlm.server if it is not already listening. Returns True on
    success. Thread-safe; concurrent callers wait for one startup."""
    global _backend_proc
    with _state_lock:
        if _backend_port_open():
            _touch()
            return True
        _log("starting backend (cold load)")
        logf = open(os.path.join(LOG_DIR, "server.log"), "a")
        proc = subprocess.Popen(
            [BACKEND_BIN, "--model", BACKEND_MODEL,
             "--host", BACKEND_HOST, "--port", str(BACKEND_PORT)],
            stdout=logf, stderr=subprocess.STDOUT,
            start_new_session=True,
        )
        _backend_proc = proc
    deadline = time.time() + BACKEND_START_TIMEOUT
    while time.time() < deadline:
        if _backend_port_open():
            _log("backend up")
            _touch()
            return True
        if proc.poll() is not None:
            _log(f"backend exited early rc={proc.returncode}")
            return False
        time.sleep(1)
    _log("backend start timed out")
    return False


def _unload_backend():
    global _backend_proc
    with _state_lock:
        proc = _backend_proc
        _backend_proc = None
    if proc is None or proc.poll() is not None:
        return
    _log("idle: stopping backend")
    try:
        os.killpg(proc.pid, signal.SIGTERM)
    except (ProcessLookupError, PermissionError):
        return
    try:
        proc.wait(timeout=30)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass


def _idle_watchdog():
    while True:
        time.sleep(15)
        if _inflight == 0 and _backend_ours() and _backend_port_open():
            if time.time() - _last_used > IDLE_SECONDS:
                _unload_backend()


HOP_BY_HOP = {"connection", "keep-alive", "proxy-authenticate",
              "proxy-authorization", "te", "trailers",
              "transfer-encoding", "upgrade", "content-length"}


class ProxyHandler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    timeout = 900

    def log_message(self, format, *args):  # noqa: A002
        _log("%s %s" % (self.address_string(), format % args))

    def _proxy(self, method):
        global _inflight
        if not ensure_backend():
            body = json.dumps({"error": {"message":
                "vision backend unavailable"}}).encode()
            self.send_response(503)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        length = int(self.headers.get("Content-Length") or 0)
        req_body = self.rfile.read(length) if length else None
        _inflight += 1
        conn = None
        try:
            body = b""
            status = 502
            headers = []
            # Retry 5xx: the 9B text server and this VLM together sit near
            # the wired GPU cap, so a vision request can Metal-OOM under
            # transient pressure and succeed a few seconds later.
            for attempt in range(RETRIES + 1):
                conn = http.client.HTTPConnection(BACKEND_HOST, BACKEND_PORT,
                                                  timeout=900)
                conn.request(method, self.path, body=req_body,
                             headers={k: v for k, v in self.headers.items()
                                      if k.lower() not in HOP_BY_HOP})
                resp = conn.getresponse()
                body = resp.read()
                status = resp.status
                headers = resp.getheaders()
                if status < 500 or attempt == RETRIES:
                    break
                _log(f"backend {status}, retry {attempt + 1}/{RETRIES}")
                conn.close()
                conn = None
                time.sleep(RETRY_DELAY)
            # Send the buffered response with an explicit Content-Length.
            # Pass-through framing (forwarding chunked or stripping
            # Content-Length) breaks keep-alive clients (httpx / the OpenAI
            # SDK): with no framing and no Connection: close they wait
            # forever for the body terminator. Vision responses are small
            # and generation is short, so buffering is harmless and makes
            # framing unambiguous. SSE through this proxy arrives as one
            # final batch instead of incremental chunks.
            self.send_response(status)
            for k, v in headers:
                lk = k.lower()
                if lk in HOP_BY_HOP:
                    continue
                self.send_header(k, v)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if body:
                _touch()
                self.wfile.write(body)
            self.wfile.flush()
        except (http.client.HTTPException, OSError) as e:
            _log(f"proxy error: {e!r}")
        finally:
            if conn is not None:
                conn.close()
            _inflight -= 1
            _touch()

    def do_GET(self):
        # Answer model listings without cold-starting the backend, so health
        # probes (Hermes startup checks, curl) never trigger a model load.
        if self.path.split("?")[0].rstrip("/") == "/v1/models":
            body = json.dumps({"object": "list", "data": [
                {"id": BACKEND_MODEL, "object": "model",
                 "owned_by": "vision-ondemand"}]}).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        self._proxy("GET")

    def do_POST(self):
        self._proxy("POST")


def main():
    os.makedirs(LOG_DIR, exist_ok=True)
    threading.Thread(target=_idle_watchdog, daemon=True).start()
    server = http.server.ThreadingHTTPServer(
        (LISTEN_HOST, LISTEN_PORT), ProxyHandler)
    _log(f"vision proxy listening on {LISTEN_HOST}:{LISTEN_PORT} "
         f"(idle unload after {IDLE_SECONDS}s)")
    server.serve_forever()


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""LAN bridge for the local-models pause flag.

Home Assistant's REST switch polls GET /state and toggles via POST /state
with {"state": "running"|"paused"} (idempotent set, so no toggle race).
Runs ~/scripts/local-models, which owns the actual flag file — this server
holds no state of its own.

Auth: Bearer token required, checked against HASS_TOKEN in ~/.hermes/.env
(read per request, so a token rotation needs no restart). Same token HA
already has; nothing new is stored anywhere.
"""
import json
import os
import subprocess
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 8086
TOGGLE_SCRIPT = os.path.expanduser("~/scripts/local-models")
ENV_FILE = os.path.expanduser("~/.hermes/.env")
FLAG_PATH = os.path.expanduser("~/.local/state/local-models.paused")


def bearer_token():
    try:
        with open(ENV_FILE, encoding="utf-8") as f:
            for line in f:
                if line.startswith("HASS_TOKEN="):
                    return line.strip().split("=", 1)[1].strip()
    except OSError:
        pass
    return None


def is_paused():
    return os.path.exists(FLAG_PATH)


def set_state(running):
    subprocess.run(
        [TOGGLE_SCRIPT, "resume" if running else "pause"],
        check=True, timeout=60, capture_output=True,
    )
    return is_paused()


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        pass

    def _authorized(self):
        token = bearer_token()
        if not token:
            return False
        auth = self.headers.get("Authorization", "")
        return auth == f"Bearer {token}"

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

    def do_GET(self):
        if not self._authorized():
            return self._send_json(401, {"error": "unauthorized"})
        if self.path.rstrip("/") != "/state":
            return self._send_json(404, {"error": "not found"})
        self._send_json(200, {"paused": is_paused()})

    def do_POST(self):
        if not self._authorized():
            return self._send_json(401, {"error": "unauthorized"})
        if self.path.rstrip("/") != "/state":
            return self._send_json(404, {"error": "not found"})
        length = int(self.headers.get("Content-Length") or 0)
        try:
            req = json.loads(self.rfile.read(length) or b"{}")
        except json.JSONDecodeError:
            return self._send_json(400, {"error": "invalid json"})
        if isinstance(req.get("state"), str):
            want_paused = req["state"].strip().lower() == "paused"
        elif isinstance(req.get("paused"), bool):
            want_paused = req["paused"]
        else:
            return self._send_json(400, {"error": "need state or paused field"})
        if is_paused() != want_paused:
            try:
                set_state(not want_paused)
            except (subprocess.SubprocessError, OSError) as exc:
                return self._send_json(500, {"error": str(exc)})
        self._send_json(200, {"paused": is_paused()})


class Server(ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = True


if __name__ == "__main__":
    Server((LISTEN_HOST, LISTEN_PORT), Handler).serve_forever()

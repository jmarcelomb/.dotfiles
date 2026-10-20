#!/usr/bin/env python3
"""Priority proxy for mlx_lm.server.

Listens on 8080, forwards to mlx_lm on 8083. Requests carrying the
background API key (only Hindsight's retain role sends it) are held while
any priority request is in flight or waiting; everything else forwards
immediately. mlx_lm serves one request at a time anyway, so this only
changes WHO waits: background never delays priority.

No circular wait is possible: priority requests are never held.
"""
import socket
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

UPSTREAM_HOST = "127.0.0.1"
UPSTREAM_PORT = 8083
BACKGROUND_KEY = "hindsight-retain"
UPSTREAM_TIMEOUT = 1800  # mlx_lm prefills of ~64k can take a while
LISTEN_PORT = 8080

lock = threading.Condition()
priority_inflight = 0
priority_waiting = 0


def is_background(headers):
    auth = headers.get("Authorization", "") or headers.get("authorization", "")
    return BACKGROUND_KEY in auth


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        pass

    def _relay(self):
        global priority_inflight, priority_waiting
        background = is_background(self.headers)

        if background:
            with lock:
                while priority_inflight > 0 or priority_waiting > 0:
                    lock.wait()
        with lock:
            priority_inflight += 1
        try:
            self._forward()
        finally:
            with lock:
                priority_inflight -= 1
                lock.notify_all()

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
    Server(("127.0.0.1", LISTEN_PORT), Handler).serve_forever()

//! On-demand vision proxy for mlx_vlm.server (rust port of the stdlib
//! python vision-ondemand.py: same launchd slot, same API, same behavior).
//!
//! Listens on 127.0.0.1:8081 and speaks the OpenAI API: on the first real
//! request it starts mlx_vlm.server on 127.0.0.1:8082 (small VLM), waits
//! for the port, forwards the request, and stops the backend after
//! IDLE_SECONDS without traffic, so the vision weights only occupy memory
//! while vision is actually in use. Health probes (GET /v1/models) are
//! answered statically and never trigger a load.
//!
//! Pause-aware (scripts/local-models): while
//! ~/.local/state/local-models.paused exists, requests are refused with a
//! 503 instead of cold-starting the backend, and a running backend is
//! unloaded immediately - a pause must not leave ~2 GB of VLM wired.
//!
//! Responses are buffered and sent with an explicit Content-Length and
//! Connection: close: pass-through framing breaks keep-alive clients
//! (httpx / the OpenAI SDK). Vision responses are small, so buffering is
//! harmless and makes framing unambiguous.
//!
//! Std-only, thread per connection; traffic is a few requests per day,
//! so no async runtime or HTTP framework.

use std::env;
use std::fs::{self, OpenOptions};
use std::io::{BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::os::unix::process::CommandExt;
use std::path::PathBuf;
use std::process::{Child, Command, Stdio};
use std::sync::{Mutex, MutexGuard};
use std::thread;
use std::time::{Duration, Instant};

use nix::sys::signal::{kill, Signal};
use nix::unistd::Pid;

const HOP_BY_HOP: [&str; 9] = [
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
    "content-length",
];

struct Cfg {
    listen_port: u16,
    backend_port: u16,
    backend_bin: PathBuf,
    backend_model: String,
    start_timeout: Duration,
    idle_seconds: Duration,
    retries: u32,
    retry_delay: Duration,
    log_dir: PathBuf,
    pause_flag: PathBuf,
}

fn load_cfg() -> Cfg {
    // launchd user agents always set HOME; fail loudly instead of guessing
    // a path (this repo is public - no usernames in source).
    let home = PathBuf::from(env::var("HOME").expect("HOME not set"));
    let num = |key: &str, default: u64| {
        env::var(key).ok().and_then(|v| v.parse().ok()).unwrap_or(default)
    };
    Cfg {
        listen_port: num("MLX_VISION_LISTEN_PORT", 8081) as u16,
        backend_port: num("MLX_VISION_BACKEND_PORT", 8082) as u16,
        backend_bin: env::var("MLX_VISION_BACKEND_BIN")
            .map(PathBuf::from)
            .unwrap_or_else(|_| home.join(".local/bin/mlx_vlm.server")),
        backend_model: "mlx-community/Qwen3.5-4B-4bit".into(),
        start_timeout: Duration::from_secs(num("MLX_VISION_START_TIMEOUT", 300)),
        idle_seconds: Duration::from_secs(num("MLX_VISION_IDLE_SECONDS", 600)),
        retries: num("MLX_VISION_RETRIES", 2) as u32,
        retry_delay: Duration::from_secs(5),
        log_dir: home.join("Library/Logs/mlx-vision"),
        pause_flag: home.join(".local/state/local-models.paused"),
    }
}

struct State {
    child: Option<Child>,
    inflight: u32,
    bg_inflight: u32,
    priority_waiting: u32,
    last_used: Instant,
}

/// Priority lane: how many background-marked requests may be in flight at the
/// backend simultaneously (1 = an interactive request queues behind at most one
/// caption), and how long a held background request waits before giving up.
const BG_LIMIT: u32 = 1;
const BG_WAIT_TIMEOUT: Duration = Duration::from_secs(300);

fn log(cfg: &Cfg, msg: &str) {
    let line = format!("{} {}\n", fmt_now(), msg);
    let _ = fs::create_dir_all(&cfg.log_dir);
    if let Ok(mut f) = OpenOptions::new()
        .create(true)
        .append(true)
        .open(cfg.log_dir.join("proxy.log"))
    {
        let _ = f.write_all(line.as_bytes());
    }
}

/// UTC timestamp, civil-from-days (Howard Hinnant); std-only, no chrono.
fn fmt_now() -> String {
    let secs = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    let days = (secs / 86_400) as i64;
    let rem = secs % 86_400;
    let (h, m, s) = (rem / 3600, (rem % 3600) / 60, rem % 60);
    let z = days + 719_468;
    let era = z / 146_097;
    let doe = (z - era * 146_097) as u64;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let y = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let month = if mp < 10 { mp + 3 } else { mp - 9 };
    let year = if month <= 2 { y + 1 } else { y };
    format!("{year:04}-{month:02}-{d:02} {h:02}:{m:02}:{s:02}")
}

fn paused(cfg: &Cfg) -> bool {
    cfg.pause_flag.exists()
}

fn backend_port_open(cfg: &Cfg) -> bool {
    TcpStream::connect_timeout(
        &format!("127.0.0.1:{}", cfg.backend_port)
            .parse()
            .expect("valid addr"),
        Duration::from_secs(2),
    )
    .is_ok()
}

/// SIGTERM, wait up to 30s, then SIGKILL. Signals go through the nix
/// crate (safe libc wrapper) - no shell-outs to kill binaries.
fn terminate(cfg: &Cfg, child: &mut Child, reason: &str) {
    log(cfg, &format!("{reason}: stopping backend"));
    let pid = Pid::from_raw(child.id() as i32);
    let _ = kill(pid, Signal::SIGTERM);
    let deadline = Instant::now() + Duration::from_secs(30);
    loop {
        match child.try_wait() {
            Ok(Some(_)) => return,
            Ok(None) => {}
            Err(_) => return,
        }
        if Instant::now() >= deadline {
            break;
        }
        thread::sleep(Duration::from_millis(200));
    }
    let _ = child.kill();
    let _ = child.wait();
}

/// Start mlx_vlm.server if it is not already listening. Returns success.
/// The state lock is held across startup, so concurrent callers serialize
/// behind one load (same as the python version).
fn ensure_backend(cfg: &Cfg, state: &mut MutexGuard<State>) -> bool {
    if backend_port_open(cfg) {
        state.last_used = Instant::now();
        return true;
    }
    // Whatever handle we hold is no longer serving: kill it and respawn.
    if let Some(mut child) = state.child.take() {
        terminate(cfg, &mut child, "stale backend");
    }
    log(cfg, "starting backend (cold load)");
    let logf = OpenOptions::new()
        .create(true)
        .append(true)
        .open(cfg.log_dir.join("server.log"))
        .ok();
    let mut child = match Command::new(&cfg.backend_bin)
        .arg("--model")
        .arg(&cfg.backend_model)
        .arg("--host")
        .arg("127.0.0.1")
        .arg("--port")
        .arg(cfg.backend_port.to_string())
        .stdout(logf.map(Stdio::from).unwrap_or(Stdio::null()))
        .stderr(Stdio::null())
        .process_group(0)
        .spawn()
    {
        Ok(c) => c,
        Err(e) => {
            log(cfg, &format!("backend spawn failed: {e}"));
            return false;
        }
    };
    let deadline = Instant::now() + cfg.start_timeout;
    loop {
        if backend_port_open(cfg) {
            log(cfg, "backend up");
            state.child = Some(child);
            state.last_used = Instant::now();
            return true;
        }
        match child.try_wait() {
            Ok(Some(status)) => {
                log(cfg, &format!("backend exited early rc={status}"));
                return false;
            }
            Ok(None) => {}
            Err(_) => return false,
        }
        if Instant::now() >= deadline {
            log(cfg, "backend start timed out");
            let _ = child.kill();
            let _ = child.wait();
            return false;
        }
        thread::sleep(Duration::from_secs(1));
    }
}

/// One decision, one lock: pause unloads immediately, idle unloads after
/// the timeout. inflight > 0 always defers.
fn watchdog(cfg: &'static Cfg, state: &'static Mutex<State>) {
    loop {
        thread::sleep(Duration::from_secs(15));
        let mut s = match state.lock() {
            Ok(s) => s,
            Err(_) => continue,
        };
        let Some(child) = s.child.as_mut() else {
            continue;
        };
        let running = child.try_wait().map(|w| w.is_none()).unwrap_or(false);
        if !running || s.inflight > 0 {
            continue;
        }
        if paused(cfg) {
            let mut c = s.child.take().expect("checked above");
            drop(s);
            terminate(cfg, &mut c, "pause");
        } else if s.last_used.elapsed() > cfg.idle_seconds && backend_port_open(cfg) {
            let mut c = s.child.take().expect("checked above");
            drop(s);
            terminate(cfg, &mut c, "idle");
        }
    }
}

fn send_json(stream: &mut TcpStream, status: u16, reason: &str, body: &str) {
    let head = format!(
        "HTTP/1.1 {status} {reason}\r\n\
         Content-Type: application/json\r\n\
         Content-Length: {}\r\n\
         Connection: close\r\n\r\n",
        body.len()
    );
    let _ = stream.write_all(head.as_bytes());
    let _ = stream.write_all(body.as_bytes());
    let _ = stream.flush();
}

type Request = (String, String, Vec<(String, String)>, Vec<u8>);

fn read_request(stream: &mut TcpStream) -> Option<Request> {
    let reader = &mut BufReader::new(stream.try_clone().ok()?);
    let mut request_line = String::new();
    reader.read_line(&mut request_line).ok()?;
    let mut parts = request_line.split_whitespace();
    let method = parts.next()?.to_ascii_uppercase();
    let path = parts.next()?.to_string();
    let mut headers = Vec::new();
    let mut content_length = 0usize;
    loop {
        let mut line = String::new();
        match reader.read_line(&mut line) {
            Ok(0) | Err(_) => return None,
            Ok(_) => {}
        }
        let trimmed = line.trim();
        if trimmed.is_empty() {
            break;
        }
        if let Some((name, value)) = trimmed.split_once(':') {
            let name = name.trim().to_string();
            let value = value.trim().to_string();
            if name.eq_ignore_ascii_case("content-length") {
                content_length = value.parse().unwrap_or(0);
            }
            headers.push((name, value));
        }
    }
    if content_length > 64 * 1024 * 1024 {
        return None;
    }
    let mut body = vec![0u8; content_length];
    if !body.is_empty() {
        reader.read_exact(&mut body).ok()?;
    }
    Some((method, path, headers, body))
}

fn forward(
    cfg: &Cfg,
    method: &str,
    path: &str,
    req_headers: &[(String, String)],
    body: &[u8],
) -> Result<(u16, String, Vec<(String, String)>, Vec<u8>), String> {
    let mut upstream = TcpStream::connect(("127.0.0.1", cfg.backend_port))
        .map_err(|e| format!("connect backend: {e}"))?;
    upstream.set_read_timeout(Some(Duration::from_secs(900))).ok();
    upstream.set_write_timeout(Some(Duration::from_secs(60))).ok();

    let mut req = format!("{method} {path} HTTP/1.1\r\n");
    for (name, value) in req_headers {
        let lname = name.to_ascii_lowercase();
        if HOP_BY_HOP.contains(&lname.as_str()) {
            continue;
        }
        req.push_str(&format!("{name}: {value}\r\n"));
    }
    req.push_str(&format!("Content-Length: {}\r\n", body.len()));
    req.push_str("Connection: close\r\n\r\n");
    upstream
        .write_all(req.as_bytes())
        .and_then(|_| upstream.write_all(body))
        .and_then(|_| upstream.flush())
        .map_err(|e| format!("send to backend: {e}"))?;

    let mut reader = BufReader::new(upstream);
    let mut status_line = String::new();
    reader
        .read_line(&mut status_line)
        .map_err(|_| "empty upstream response".to_string())?;
    if status_line.is_empty() {
        return Err("empty upstream response".to_string());
    }
    let mut parts = status_line.split_whitespace();
    let _http = parts.next();
    let status: u16 = parts.next().unwrap_or("502").parse().unwrap_or(502);
    let reason = parts.collect::<Vec<_>>().join(" ");
    let mut resp_headers = Vec::new();
    let mut content_length: Option<usize> = None;
    loop {
        let mut line = String::new();
        match reader.read_line(&mut line) {
            Ok(0) => break,
            Err(e) => return Err(format!("read headers: {e}")),
            Ok(_) => {}
        }
        let trimmed = line.trim();
        if trimmed.is_empty() {
            break;
        }
        if let Some((name, value)) = trimmed.split_once(':') {
            let name = name.trim().to_string();
            let lname = name.to_ascii_lowercase();
            let value = value.trim().to_string();
            if lname == "content-length" {
                content_length = value.parse().ok();
            }
            if HOP_BY_HOP.contains(&lname.as_str()) {
                continue;
            }
            resp_headers.push((name, value));
        }
    }
    let mut resp_body = Vec::new();
    match content_length {
        Some(n) => {
            resp_body = vec![0u8; n];
            reader
                .read_exact(&mut resp_body)
                .map_err(|e| format!("read body: {e}"))?;
        }
        None => {
            // No framing: the backend got Connection: close, so EOF ends it.
            reader
                .read_to_end(&mut resp_body)
                .map_err(|e| format!("read body: {e}"))?;
        }
    }
    Ok((status, reason, resp_headers, resp_body))
}

fn handle(cfg: &'static Cfg, state: &'static Mutex<State>, mut stream: TcpStream) {
    let _ = stream.set_read_timeout(Some(Duration::from_secs(900)));
    let _ = stream.set_write_timeout(Some(Duration::from_secs(900)));
    let Some((method, path, req_headers, body)) = read_request(&mut stream) else {
        return;
    };

    // Static model listing: health probes never cold-start the backend.
    if method == "GET"
        && path.split('?').next().unwrap_or("").trim_end_matches('/') == "/v1/models"
    {
        let body = format!(
            r#"{{"object": "list", "data": [{{"id": "{}", "object": "model", "owned_by": "vision-ondemand"}}]}}"#,
            cfg.backend_model
        );
        send_json(&mut stream, 200, "OK", &body);
        return;
    }

    if paused(cfg) {
        send_json(
            &mut stream,
            503,
            "Service Unavailable",
            r#"{"error": {"message": "local models paused (resume with ~/scripts/local-models resume)"}}"#,
        );
        return;
    }

    // Priority lane (same contract as mlx-lm-priority-proxy): requests marked
    // X-Priority: background (batch captioning - immich loop, messages delta)
    // are held while interactive traffic is waiting, and at most BG_LIMIT run
    // against the backend at once. The backend serializes generation anyway,
    // so throughput is unchanged; an interactive request only ever queues
    // behind the ONE in-flight caption instead of the whole batch.
    let is_bg = req_headers.iter().any(|(n, v)| {
        n.eq_ignore_ascii_case("x-priority") && v.trim().eq_ignore_ascii_case("background")
    });
    if is_bg {
        let deadline = Instant::now() + BG_WAIT_TIMEOUT;
        loop {
            {
                let mut s = match state.lock() {
                    Ok(s) => s,
                    Err(_) => return,
                };
                if s.priority_waiting == 0 && s.bg_inflight < BG_LIMIT {
                    s.bg_inflight += 1;
                    break;
                }
            }
            if Instant::now() >= deadline {
                send_json(
                    &mut stream,
                    503,
                    "Service Unavailable",
                    r#"{"error": {"message": "vision proxy busy: background request yielded to interactive traffic"}}"#,
                );
                return;
            }
            thread::sleep(Duration::from_millis(100));
        }
    } else if let Ok(mut s) = state.lock() {
        s.priority_waiting += 1;
    }
    // Release admission counters on ANY exit path past this point.
    struct Admission<'a>(&'a Mutex<State>, bool);
    impl Drop for Admission<'_> {
        fn drop(&mut self) {
            if let Ok(mut s) = self.0.lock() {
                if self.1 {
                    s.bg_inflight = s.bg_inflight.saturating_sub(1);
                } else {
                    s.priority_waiting = s.priority_waiting.saturating_sub(1);
                }
            }
        }
    }
    let _admission = Admission(state, is_bg);

    {
        let mut s = match state.lock() {
            Ok(s) => s,
            Err(_) => return,
        };
        if !ensure_backend(cfg, &mut s) {
            send_json(
                &mut stream,
                503,
                "Service Unavailable",
                r#"{"error": {"message": "vision backend unavailable"}}"#,
            );
            return;
        }
        s.inflight += 1;
        s.last_used = Instant::now();
    }

    // Retry 5xx: the 9B text server and this VLM together sit near the
    // wired GPU cap, so a vision request can Metal-OOM under transient
    // pressure and succeed a few seconds later.
    let mut out: Result<(u16, String, Vec<(String, String)>, Vec<u8>), String> =
        Err("no attempt".into());
    for attempt in 0..=cfg.retries {
        match forward(cfg, &method, &path, &req_headers, &body) {
            Ok((status, reason, headers, resp_body)) => {
                let last = attempt == cfg.retries;
                out = Ok((status, reason, headers, resp_body));
                if status < 500 || last {
                    break;
                }
                log(cfg, &format!("backend {status}, retry {}/{}", attempt + 1, cfg.retries));
                thread::sleep(cfg.retry_delay);
            }
            Err(e) => {
                log(cfg, &format!("proxy error: {e}"));
                out = Err(e);
                break;
            }
        }
        touch(state);
    }

    if let Ok(mut s) = state.lock() {
        s.inflight = s.inflight.saturating_sub(1);
        s.last_used = Instant::now();
    }

    match out {
        Ok((status, reason, headers, resp_body)) => {
            respond(&mut stream, status, &reason, &headers, &resp_body);
        }
        Err(e) => {
            let safe = e.replace('"', "");
            send_json(
                &mut stream,
                502,
                "Bad Gateway",
                &format!(r#"{{"error": {{"message": "{safe}"}}}}"#),
            );
        }
    }
}

fn touch(state: &Mutex<State>) {
    if let Ok(mut s) = state.lock() {
        s.last_used = Instant::now();
    }
}

fn respond(
    stream: &mut TcpStream,
    status: u16,
    reason: &str,
    headers: &[(String, String)],
    body: &[u8],
) {
    let mut head = format!("HTTP/1.1 {status} {reason}\r\n");
    for (name, value) in headers {
        let lname = name.to_ascii_lowercase();
        if HOP_BY_HOP.contains(&lname.as_str()) {
            continue;
        }
        head.push_str(&format!("{name}: {value}\r\n"));
    }
    head.push_str(&format!("Content-Length: {}\r\n", body.len()));
    head.push_str("Connection: close\r\n\r\n");
    let _ = stream.write_all(head.as_bytes());
    if !body.is_empty() {
        let _ = stream.write_all(body);
    }
    let _ = stream.flush();
}

fn main() {
    let cfg: &'static Cfg = Box::leak(Box::new(load_cfg()));
    let state: &'static Mutex<State> = Box::leak(Box::new(Mutex::new(State {
        child: None,
        inflight: 0,
        bg_inflight: 0,
        priority_waiting: 0,
        last_used: Instant::now(),
    })));
    let _ = fs::create_dir_all(&cfg.log_dir);
    log(
        cfg,
        &format!(
            "vision proxy listening on 127.0.0.1:{} (idle unload after {}s)",
            cfg.listen_port,
            cfg.idle_seconds.as_secs()
        ),
    );
    thread::spawn(move || watchdog(cfg, state));
    let listener = TcpListener::bind(("127.0.0.1", cfg.listen_port))
        .expect("bind vision proxy port");
    for stream in listener.incoming() {
        if let Ok(stream) = stream {
            thread::spawn(move || handle(cfg, state, stream));
        }
    }
}

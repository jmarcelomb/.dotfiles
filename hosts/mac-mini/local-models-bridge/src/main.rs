//! LAN bridge for the local-models pause flag.
//!
//! Home Assistant's REST switch polls GET /state and toggles via
//! POST /state with {"state": "running"|"paused"} (idempotent set, so no
//! toggle race). Runs ~/scripts/local-models, which owns the actual flag
//! file — this server holds no state of its own.
//!
//! Auth: Bearer token required, checked against HASS_TOKEN in
//! ~/.hermes/.env (read per request, so a token rotation needs no
//! restart). Same token HA already has; nothing new is stored anywhere.

use axum::extract::rejection::JsonRejection;
use axum::http::{header, HeaderMap, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::routing::get;
use axum::{Json, Router};
use serde::Deserialize;
use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct SetState {
    state: Option<String>,
    paused: Option<bool>,
}

fn home_file(rel: &str) -> PathBuf {
    let home = env::var("HOME").unwrap_or_else(|_| "/Users/jmmb".to_string());
    PathBuf::from(home).join(rel)
}

fn bearer_token() -> Option<String> {
    let data = fs::read_to_string(home_file(".hermes/.env")).ok()?;
    data.lines()
        .find_map(|line| line.strip_prefix("HASS_TOKEN="))
        .map(|rest| rest.trim().to_string())
}

fn is_paused() -> bool {
    home_file(".local/state/local-models.paused").exists()
}

fn set_state(running: bool) -> Result<bool, String> {
    let script = home_file("scripts/local-models");
    let out = Command::new(&script)
        .arg(if running { "resume" } else { "pause" })
        .output()
        .map_err(|e| format!("spawn {}: {e}", script.display()))?;
    if !out.status.success() {
        let stderr = String::from_utf8_lossy(&out.stderr);
        return Err(format!("local-models exited {}: {}", out.status, stderr.trim()));
    }
    Ok(is_paused())
}

fn error(status: StatusCode, msg: &str) -> Response {
    (status, Json(serde_json::json!({ "error": msg }))).into_response()
}

fn authorize(headers: &HeaderMap) -> Result<(), Response> {
    let Some(token) = bearer_token() else {
        return Err(error(StatusCode::INTERNAL_SERVER_ERROR, "token unavailable"));
    };
    let expected = format!("Bearer {token}");
    let got = headers
        .get(header::AUTHORIZATION)
        .and_then(|value| value.to_str().ok());
    match got {
        Some(value) if value == expected => Ok(()),
        _ => Err(error(StatusCode::UNAUTHORIZED, "unauthorized")),
    }
}

async fn get_state(headers: HeaderMap) -> Response {
    if let Err(response) = authorize(&headers) {
        return response;
    }
    (
        StatusCode::OK,
        Json(serde_json::json!({ "paused": is_paused() })),
    )
        .into_response()
}

async fn post_state(headers: HeaderMap, body: Result<Json<SetState>, JsonRejection>) -> Response {
    if let Err(response) = authorize(&headers) {
        return response;
    }
    let Ok(Json(req)) = body else {
        return error(StatusCode::BAD_REQUEST, "need state or paused field");
    };
    // Idempotent set, not a toggle: both fields mean the same thing so a
    // retry or a stale poll can never double-toggle.
    let want_paused = match (req.state.as_deref(), req.paused) {
        (Some("paused"), _) | (_, Some(true)) => true,
        (Some("running"), _) | (_, Some(false)) => false,
        _ => return error(StatusCode::BAD_REQUEST, "need state or paused field"),
    };
    if is_paused() != want_paused {
        if let Err(e) = set_state(!want_paused) {
            return error(StatusCode::INTERNAL_SERVER_ERROR, &e);
        }
    }
    (
        StatusCode::OK,
        Json(serde_json::json!({ "paused": is_paused() })),
    )
        .into_response()
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/state", get(get_state).post(post_state));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:8086")
        .await
        .expect("bind 0.0.0.0:8086");
    axum::serve(listener, app).await.expect("serve");
}

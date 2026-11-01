# Remote dashboard (hermes dashboard) bound to the NetBird interface.
#
# Serves the web dashboard + /api/ws + /api/pty to mesh peers only
# (phone app, browser extension, remote Hermes Desktop). Binding to the
# NetBird IP instead of 0.0.0.0 means nothing on the LAN or internet can
# reach it — only enrolled peers.
#
# Auth: the non-loopback bind engages the fail-closed auth gate; the
# basic provider (username/password) is configured entirely via env in
# ~/.hermes/.env (HERMES_DASHBOARD_BASIC_AUTH_USERNAME/PASSWORD/SECRET —
# env wins over config.yaml per plugins/dashboard_auth/basic). A
# self-connection to the NetBird IP times out locally (WireGuard
# hairpin); test from an actual peer.
#
# Restarting this service does not touch the messaging gateway.
{ homeDirectory, ... }:

let
  cfg = {
    host = "100.106.113.49"; # this peer's stable NetBird IP
    port = 9119;
    bin = "${homeDirectory}/.local/bin/hermes";
    envFile = "${homeDirectory}/.hermes/.env";
    logDir = "${homeDirectory}/.hermes/logs";
  };
in
{
  launchd.user.agents.hermes-dashboard = {
    script = ''
      set -a
      . ${cfg.envFile}
      set +a
      exec ${cfg.bin} dashboard \
        --host ${cfg.host} \
        --port "${toString cfg.port}" \
        --no-open
    '';
    serviceConfig = {
      Label = "com.user.hermes-dashboard";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/dashboard-remote.log";
      StandardErrorPath = "${cfg.logDir}/dashboard-remote.log";
    };
  };
}

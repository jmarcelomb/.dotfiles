# Remote dashboard (hermes dashboard) on the LAN + NetBird interfaces.
#
# Serves the web dashboard + /api/ws + /api/pty to mesh peers and to the home
# LAN. Bound to 0.0.0.0 so the desktop app's "Second Address" fallback
# (http://192.168.0.69:9119) answers when NetBird is down; a second dashboard
# process was rejected — one process, one session DB. Reachability is LAN +
# enrolled peers only (no router port-forward); a self-connection to the
# NetBird IP times out locally (WireGuard hairpin), so test from a peer.
#
# Auth: the non-loopback bind engages the fail-closed auth gate; the basic
# provider (username/password) is configured entirely via env in
# ~/.hermes/.env (HERMES_DASHBOARD_BASIC_AUTH_USERNAME/PASSWORD_HASH/SECRET —
# env wins over config.yaml per plugins/dashboard_auth/basic). Note the LAN
# leg is plain HTTP: the password and session cookie cross the LAN in clear.
#
# 192.168.0.69 is a DHCP lease (en0); keep a fixed-IP reservation on the
# router or the fallback address moves.
#
# Restarting this service does not touch the messaging gateway.
{ homeDirectory, ... }:

let
  cfg = {
    host = "0.0.0.0";
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

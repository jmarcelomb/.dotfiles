# Watchdog for the local text-model stack.
#
# 2026-11-14: mlx_lm.server is no longer a launchd agent. The priority proxy
# (mlx-lm-priority-proxy.nix, :8080) owns the backend on :8083 — it spawns it
# on the first real request and unloads it after MLX_LM_IDLE_SECONDS, so the
# 9B weights only occupy memory while local models are used.
#
# Consequences for this file:
#   - The old canary (a real chat completion every 5 min) would cold-start the
#     model on every cycle and defeat the idle unload, so it is gone. The idle
#     timer is now the wedge recovery: a stalled backend with no traffic is
#     unloaded, and the next request spawns a fresh one.
#   - Metal-OOM ("generation thread died") detection moved into the proxy's
#     log tailer, which kills the backend so the next request respawns it.
#   - What remains is proxy liveness: the proxy is stateless, so restarting it
#     is always safe (a running backend is adopted via its listening port and
#     cleaned up by the idle watchdog, orphan PIDs included).
#
# server.log stays in place: the proxy redirects the backend's stdout there
# and the newsyslog rule below rotates it.
{ user, homeDirectory, ... }:

let
  cfg = {
    proxyPort = 8080;
    logDir = "${homeDirectory}/Library/Logs/mlx-lm";
    # log rotation (newsyslog): rotate when log passes maxLogSizeMB,
    # keep maxArchives compressed copies
    maxLogSizeMB = 10;
    maxArchives = 3;
  };
in
{
  launchd.user.agents.mlx-lm-watchdog = {
    script = ''
      # While the local-models pause flag exists the servers are gated off
      # by design and the proxy answers 503; never restart into a pause.
      [ -f ${homeDirectory}/.local/state/local-models.paused ] && exit 0
      # Static /v1/models: answered by the proxy itself, never triggers a
      # model load, so this probe costs nothing and cannot queue behind
      # generation.
      CODE=$(curl -s -o /dev/null -w '%{http_code}' -m 15 \
        http://127.0.0.1:${toString cfg.proxyPort}/v1/models)
      if [ "$CODE" != "200" ]; then
        echo "$(date '+%F %T') proxy unhealthy (HTTP $CODE), restarting mlx-lm-priority-proxy" >> ${cfg.logDir}/watchdog.log
        launchctl kickstart -k gui/$(id -u)/com.user.mlx-lm-priority-proxy
      fi
    '';
    serviceConfig = {
      Label = "com.user.mlx-lm-watchdog";
      RunAtLoad = false;
      StartInterval = 300; # every 5 minutes
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/watchdog.out";
      StandardErrorPath = "${cfg.logDir}/watchdog.out";
    };
  };

  # Rotate server.log via newsyslog: when it passes maxLogSizeMB, compress it
  # and keep maxArchives copies. Disk usage stays capped at a few MB total.
  environment.etc."newsyslog.d/mlx-lm.conf".text = ''
    # logfilename                           owner:group  mode  count  size  when  flags
    ${cfg.logDir}/server.log                ${user}:staff 644  ${toString cfg.maxArchives}  ${
      toString (cfg.maxLogSizeMB * 1024)
    }  *  J
  '';
}

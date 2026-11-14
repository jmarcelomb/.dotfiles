# On-demand priority proxy in front of mlx_lm.server (binds 8080).
#
# 2026-11-14: the proxy now OWNS the backend lifecycle. mlx_lm.server on
# 8083 is no longer a launchd agent; the proxy spawns it on the first real
# request and unloads it after MLX_LM_IDLE_SECONDS (default 30) without
# traffic, so the 9B weights (~5.5 GB) sit in memory only while local
# models are used. /v1/models is answered statically so probes and model
# discovery never cold-start the model.
#
# Still a priority proxy: requests carrying the background API key
# (Hindsight's old retain role) are held while priority traffic is in
# flight; everything else forwards immediately. Streaming (SSE) is
# relayed chunk by chunk. Pure Python stdlib; no venv.
#
# Pause-aware (scripts/local-models): while the flag exists, chat requests
# get a 503 and a running backend is unloaded within one watchdog cycle.
#
# Cold start: the first request after idleness pays the model load (~10-20s
# for the 9B 4-bit); warm requests are unaffected. Raise idleness when a
# cron/session has long gaps between tool calls (>30s) and repeated reloads
# would cost more than the memory saved.
{
  pkgs,
  user,
  homeDirectory,
  ...
}:

let
  proxyScript = pkgs.writeText "mlx-lm-priority-proxy.py" ''
    ${builtins.readFile ./mlx-lm-priority-proxy.py}
  '';
  cfg = {
    # Unload the backend after this many seconds without traffic.
    idleSeconds = 30;
    # Ceiling on model load + first-request wait.
    startupTimeoutSeconds = 180;
    model = "mlx-community/Qwen3.5-9B-4bit";
    backendPort = 8083;
    logDir = "${homeDirectory}/Library/Logs/mlx-lm";
  };
in
{
  launchd.user.agents.mlx-lm-priority-proxy = {
    script = ''
      exec /usr/bin/python3 ${proxyScript}
    '';
    serviceConfig = {
      Label = "com.user.mlx-lm-priority-proxy";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      EnvironmentVariables = {
        MLX_LM_IDLE_SECONDS = toString cfg.idleSeconds;
        MLX_LM_STARTUP_TIMEOUT = toString cfg.startupTimeoutSeconds;
        MLX_LM_MODEL = cfg.model;
        MLX_LM_PORT = toString cfg.backendPort;
      };
      StandardOutPath = "${cfg.logDir}/proxy.log";
      StandardErrorPath = "${cfg.logDir}/proxy.log";
    };
  };
}

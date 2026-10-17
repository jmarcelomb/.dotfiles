# mlx-lm local inference server (mlx_lm.server) as a launchd user agent.
# Runs at login, restarts on crash. All tunables live in the cfg block below.
{ user, homeDirectory, ... }:

let
  cfg = {
    model = "mlx-community/gemma-4-12B-it-qat-4bit";
    host = "127.0.0.1";
    port = 8080;
    # uv-managed binary; stable across uv tool upgrades
    bin = "${homeDirectory}/.local/bin/mlx_lm.server";
    logDir = "${homeDirectory}/Library/Logs/mlx-lm";
  };
in
{
  launchd.user.agents.mlx-lm-server = {
    script = ''
      mkdir -p ${cfg.logDir}
      exec ${cfg.bin} \
        --model ${cfg.model} \
        --host ${cfg.host} \
        --port "${toString cfg.port}"
    '';
    serviceConfig = {
      Label = "com.user.mlx-lm-server";
      RunAtLoad = true;
      KeepAlive = true; # restart on crash
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/server.log";
      StandardErrorPath = "${cfg.logDir}/server.log";
    };
  };
}

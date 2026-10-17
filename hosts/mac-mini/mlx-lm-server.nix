# mlx-lm local inference server (mlx_lm.server) as a launchd user agent.
# Runs at login, restarts on crash. All tunables live in the cfg block below.
{ user, homeDirectory, ... }:

let
  cfg = {
    model = "mlx-community/Qwen3.5-9B-4bit";
    host = "127.0.0.1";
    port = 8080;
    # uv-managed binary; stable across uv tool upgrades
    # mlx-vlm 0.7.8+: text + tool calls + vision (gemma4_unified, qwen3_5) in one server
    bin = "${homeDirectory}/.local/bin/mlx_vlm.server";
    logDir = "${homeDirectory}/Library/Logs/mlx-lm";
    # log rotation (newsyslog): rotate when log passes maxLogSizeMB,
    # keep maxArchives compressed copies
    maxLogSizeMB = 10;
    maxArchives = 3;
    # 600s default is too short for long prefills (~19k-token cron prompts);
    # when several requests queue, prefill can exceed it and the server drops
    # the stream mid-generation ("Timed out waiting for 600s for the next
    # generated token").
    tokenQueueTimeoutS = 3600;
    # Hard KV-cache cap. Unbounded cache on 16 GB can spike wired GPU memory
    # on very long prompts; 64k covers everything Hermes sends (cron PR check
    # ~16-19k tokens) with headroom.
    maxKvSize = 65536;
  };
in
{
  launchd.user.agents.mlx-lm-server = {
    script = ''
      mkdir -p ${cfg.logDir}
      exec ${cfg.bin} \
        --model ${cfg.model} \
        --host ${cfg.host} \
        --port "${toString cfg.port}" \
        --max-kv-size "${toString cfg.maxKvSize}"
    '';
    serviceConfig = {
      Label = "com.user.mlx-lm-server";
      RunAtLoad = true;
      KeepAlive = true; # restart on crash
      ProcessType = "Background";
      EnvironmentVariables = {
        MLX_VLM_TOKEN_QUEUE_TIMEOUT = toString cfg.tokenQueueTimeoutS;
      };
      StandardOutPath = "${cfg.logDir}/server.log";
      StandardErrorPath = "${cfg.logDir}/server.log";
    };
  };

  # Rotate server.log via newsyslog: when it passes maxLogSizeMB, compress it
  # and keep maxArchives copies. Disk usage stays capped at a few MB total.
  environment.etc."newsyslog.d/mlx-lm.conf".text = ''
    # logfilename                           owner:group  mode  count  size  when  flags
    ${cfg.logDir}/server.log                ${user}:staff 644  ${toString cfg.maxArchives}  ${toString (cfg.maxLogSizeMB * 1024)}  *  J
  '';
}

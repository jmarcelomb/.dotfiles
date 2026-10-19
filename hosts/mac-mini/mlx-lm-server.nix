# Local text-model server (mlx_lm.server) as a launchd user agent.
# Runs at login, restarts on crash. All tunables live in the cfg block below.
#
# 2026-10-19: switched from mlx_vlm.server to mlx_lm.server. mlx_vlm raised
# HTTP 500 "No user query found in messages" on long tool-call histories
# (Qwen3.5 chat template raises when every user message is a tool response);
# mlx_lm 0.32.2 normalizes those payloads correctly (verified by replaying
# the failed request dump from ~/.hermes/sessions). Vision moved to a
# separate on-demand server: see mlx-vision-ondemand.nix.
{ user, homeDirectory, ... }:

let
  cfg = {
    model = "mlx-community/Qwen3.5-9B-4bit";
    host = "127.0.0.1";
    port = 8080;
    # uv-managed binary; stable across uv tool upgrades
    bin = "${homeDirectory}/.local/bin/mlx_lm.server";
    logDir = "${homeDirectory}/Library/Logs/mlx-lm";
    # log rotation (newsyslog): rotate when log passes maxLogSizeMB,
    # keep maxArchives compressed copies
    maxLogSizeMB = 10;
    maxArchives = 3;
    # mlx_lm has no up-front KV reservation (unlike mlx_vlm's --max-kv-size):
    # KV is allocated per request and the prompt cache evicts entries when
    # the total passes this byte budget. 6 GiB admits one ~32k-token request
    # (fp16 KV ~5.4 GiB) alongside small ones, matching the effective reach
    # of the old 32k cap without starving the machine when idle.
    promptCacheBytes = 6442450944;
    # Cap concurrent decodes: several parallel big prefills Metal-OOM
    # ("Insufficient Memory") on 16 GB. Extra requests queue (backpressure).
    decodeConcurrency = 2;
    # OPTIONAL 64k context: add "--kv-bits 8" below. 8-bit KV halves the
    # per-token cost (~5.4 GiB for 64k instead of ~10.7 GiB), but disables
    # batching (requests serialize) and slightly degrades long-context
    # quality. Never raise context without it: 64k fp16 KV plus ~5.5 GB
    # weights exceeds the machine budget (the math that killed the 64k
    # mlx_vlm cap on 2026-10-17).
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
        --prompt-cache-bytes "${toString cfg.promptCacheBytes}" \
        --decode-concurrency "${toString cfg.decodeConcurrency}"
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

  # Canary watchdog: mlx_lm's generation thread dies permanently on GPU OOM
  # ("generation thread died"; every subsequent request 404s until restart —
  # seen 2026-10-19 when a 49k-token prompt OOMed at 28.6k prefill). This
  # agent runs a minimal chat completion every 5 minutes; if it fails,
  # kickstart the server. Cheap on a warm prompt cache (~1s).
  launchd.user.agents.mlx-lm-watchdog = {
    script = ''
      CODE=$(curl -s -o /dev/null -w '%{http_code}' -m 90 \
        http://127.0.0.1:8080/v1/chat/completions \
        -H 'Content-Type: application/json' \
        -d '{"model":"${cfg.model}","max_tokens":1,"chat_template_kwargs":{"enable_thinking":false},"messages":[{"role":"user","content":"ping"}]}')
      if [ "$CODE" != "200" ]; then
        echo "$(date '+%F %T') canary failed (HTTP $CODE), restarting mlx-lm-server" >> ${cfg.logDir}/watchdog.log
        launchctl kickstart -k gui/$(id -u)/com.user.mlx-lm-server
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
    ${cfg.logDir}/server.log                ${user}:staff 644  ${toString cfg.maxArchives}  ${toString (cfg.maxLogSizeMB * 1024)}  *  J
  '';
}

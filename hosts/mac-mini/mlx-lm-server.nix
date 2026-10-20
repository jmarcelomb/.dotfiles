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
    # the total passes this byte budget. 3 GiB: big enough to keep both
    # consumers' system prompts warm, small enough that weights (~5.5 GB)
    # + cache + a full 64k 8-bit KV (~5.3 GB) stay inside the GPU wired
    # limit. The 7 GiB budget OOMed Metal during large prefills
    # (2026-10-20: Insufficient Memory at 24k prefill with a 4.4 GB cache).
    promptCacheBytes = 3221225472; # 3 GiB
    # 8-bit KV cache: halves the per-token cost, which is what makes the
    # 64k context Hermes requires (MINIMUM_CONTEXT_LENGTH floor) fit next
    # to the ~5.5 GB weights on 16 GB (64k fp16 KV would be ~10.9 GB and
    # Metal-OOM at ~28k prefill - observed 2026-10-19). Trade-off: kv-bits
    # disables batching, so requests are served one at a time (extra ones
    # queue); decodeConcurrency is therefore omitted. Slight quality loss
    # on very long contexts.
    kvBits = 8;
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
        --kv-bits "${toString cfg.kvBits}"
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
  #
  # CRITICAL: only a DEFINITIVE failure justifies a restart. HTTP 000 means
  # the canary timed out or could not connect — on a single-slot server
  # serving a long Hindsight extraction, a healthy server just queues the
  # canary. Kicking it kills the in-flight request (2026-10-20: the canary
  # restarted the server every ~5 min all day while Hindsight's backlog
  # kept it busy, dropping every request in flight). The dead-thread case
  # this watchdog exists for answers 404 immediately, and a wedged server
  # answers 5xx — both arrive long before the 180s timeout.
  launchd.user.agents.mlx-lm-watchdog = {
    script = ''
      CODE=$(curl -s -o /dev/null -w '%{http_code}' -m 180 \
        http://127.0.0.1:8080/v1/chat/completions \
        -H 'Content-Type: application/json' \
        -d '{"model":"${cfg.model}","max_tokens":1,"chat_template_kwargs":{"enable_thinking":false},"messages":[{"role":"user","content":"ping"}]}')
      if [ "$CODE" = "404" ] || [ "$CODE" -ge 500 ] 2>/dev/null; then
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

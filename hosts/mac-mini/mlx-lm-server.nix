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
    # Moved behind the priority proxy: mlx_lm binds 8083, the proxy binds
    # 8080 (the port Hermes and Hindsight both target) and yields
    # Hindsight's retain traffic to Hermes chat. See
    # mlx-lm-priority-proxy.nix.
    port = 8083;
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
    promptCacheBytes = 1610612736; # 1.5 GiB - lowered from 3 GiB to prevent Metal OOM on 16GB (2026-10-22)
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
      # Server runs in the background with a log-tail supervisor. mlx_lm's
      # unrecoverable failure mode is a Metal OOM that kills ONLY the
      # generation thread while the HTTP process keeps serving 404s
      # forever - launchd KeepAlive never sees a death. Watching the log
      # for that exact line and killing the process gives Ollama-class
      # self-healing (seconds to recovery) instead of waiting up to 5
      # minutes for the canary (which stays as last resort for wedged
      # servers that log nothing).
      ${cfg.bin} \
        --model ${cfg.model} \
        --host ${cfg.host} \
        --port "${toString cfg.port}" \
        --prompt-cache-bytes "${toString cfg.promptCacheBytes}" \
        --kv-bits "${toString cfg.kvBits}" &
      SERVER_PID=$!
      cleanup() {
        kill "$SERVER_PID" 2>/dev/null
        [ -n "''${TAIL_PID:-}" ] && kill "$TAIL_PID" 2>/dev/null
      }
      trap cleanup EXIT INT TERM
      tail -n 0 -F ${cfg.logDir}/server.log 2>/dev/null | while read -r LINE; do
        case "$LINE" in
          *"generation thread died"*|*"Insufficient Memory"*|*"Command buffer execution failed"*)
            echo "$(date '+%F %T') generation thread died, restarting mlx-lm-server" >> ${cfg.logDir}/watchdog.log
            kill -9 "$SERVER_PID" 2>/dev/null
            ;;
        esac
      done &
      TAIL_PID=$!
      wait "$SERVER_PID"
      exit 0
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
  #
  # SILENT WEDGE (seen 2026-10-29, hung ~1h with cron dead all day): after a
  # big prefill the generation thread can stall WITHOUT logging anything and
  # WITHOUT dying — /v1/models still answers 200, chat completions hang
  # forever, and the canary times out as plain 000, so the old rule never
  # fired. Discriminator from a healthy server busy decoding a thinking
  # extraction (which also logs nothing during decode): live decode holds
  # ~30%+ CPU on the server process, a silent wedge sits near 0%. So on a
  # canary timeout we sample CPU twice; near-idle twice in a row = wedge,
  # kickstart. The in-flight request is a dead client anyway (both prior
  # callers gave up), so nothing of value is lost.
  launchd.user.agents.mlx-lm-watchdog = {
    script = ''
      CODE=$(curl -s -o /dev/null -w '%{http_code}' -m 120 \
        http://127.0.0.1:8083/v1/chat/completions \
        -H 'Content-Type: application/json' \
        -d '{"model":"${cfg.model}","max_tokens":1,"chat_template_kwargs":{"enable_thinking":false},"messages":[{"role":"user","content":"ping"}]}')
      if [ "$CODE" = "404" ] || [ "$CODE" -ge 500 ] 2>/dev/null; then
        echo "$(date '+%F %T') canary failed (HTTP $CODE), restarting mlx-lm-server" >> ${cfg.logDir}/watchdog.log
        launchctl kickstart -k gui/$(id -u)/com.user.mlx-lm-server
      elif [ "$CODE" = "000" ]; then
        # Timeout: healthy decode vs silent wedge. ps %cpu on macOS is a
        # decayed recent-usage average, so a live decode stays high across
        # both samples while a stalled thread decays toward 0.
        PID=$(pgrep -f "mlx_lm.server --model" | head -1)
        if [ -n "$PID" ]; then
          C1=$(ps -o %cpu= -p "$PID" | tr -d ' ' || echo 100)
          sleep 30
          C2=$(ps -o %cpu= -p "$PID" 2>/dev/null | tr -d ' ' || echo 100)
          IDLE=$(awk -v a="$C1" -v b="$C2" 'BEGIN{print (a<5 && b<5)?1:0}')
          if [ "$IDLE" = "1" ]; then
            echo "$(date '+%F %T') silent wedge (canary 000, cpu $C1/$C2), restarting mlx-lm-server" >> ${cfg.logDir}/watchdog.log
            launchctl kickstart -k gui/$(id -u)/com.user.mlx-lm-server
          else
            echo "$(date '+%F %T') canary 000 but cpu $C1/$C2 (live decode), waiting" >> ${cfg.logDir}/watchdog.log
          fi
        fi
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

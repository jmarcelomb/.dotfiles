# Dedicated Hindsight extraction server (mlx_lm.server, gemma-4-e2b-it-4bit).
#
# 2026-10-30 bench (3 real retain chunks, solo, real Hindsight prompt):
# gemma-4-e2b-it-4bit with thinking 31-38s/chunk vs Qwen3.5-9B no-think
# 45-86s — and it decouples Hindsight's retains from Hermes chat entirely.
# Every failure mode of 2026-10-29 (thinking retains monopolizing the
# single-slot 9B behind the priority proxy, starving Telegram for 78 min)
# came from the two consumers sharing one server. E2B weights ~3.4 GB sit
# next to the 9B's ~4.7 GB on 16 GB; extraction prompts are ~6k tokens so
# its KV footprint is small.
#
# gemma-4 thinks by default; Hindsight runs with thinking ON here (bench
# winner: 11 facts with dates vs 9 no-think) — a full E2B thinking run is
# ~40s, an orphaned one self-clears in ~2-3 min, unlike the 9B's 15-25 min.
{ user, homeDirectory, ... }:

let
  cfg = {
    model = "mlx-community/gemma-4-e2b-it-4bit";
    host = "127.0.0.1";
    port = 8085;
    bin = "${homeDirectory}/.local/bin/mlx_lm.server";
    logDir = "${homeDirectory}/Library/Logs/mlx-hindsight";
    maxLogSizeMB = 10;
    maxArchives = 3;
  };
in
{
  launchd.user.agents.mlx-hindsight-server = {
    script = ''
      mkdir -p ${cfg.logDir}
      # Pause gate (scripts/local-models): hold here instead of loading
      # weights while ~/.local/state/local-models.paused exists. Same
      # mechanics as mlx-lm-server.nix — see the long comment there.
      while [ -f ${homeDirectory}/.local/state/local-models.paused ]; do
        sleep 15
      done
      # Same log-tail supervisor as mlx-lm-server: a Metal OOM kills only
      # the generation thread while HTTP keeps serving 404s forever.
      # Default output cap. Hindsight omits max_tokens on most scopes (only
      # verification sends one), and mlx_lm.server's implicit default of 512
      # truncates consolidation merges (OutputTooLongError bisect loops,
      # 2026-11-07). The env-level pin
      # HINDSIGHT_API_CONSOLIDATION_MAX_COMPLETION_TOKENS=8192 covers
      # consolidation explicitly; this covers everything else.
      ${cfg.bin} \
        --model ${cfg.model} \
        --host ${cfg.host} \
        --port "${toString cfg.port}" \
        --max-tokens 8192 &
      SERVER_PID=$!
      # Pause monitor: see mlx-lm-server.nix. KeepAlive restarts into the
      # gate above once the flag appears and the server dies.
      (
        while [ ! -f ${homeDirectory}/.local/state/local-models.paused ]; do
          sleep 15
        done
        echo "$(date '+%F %T') pause flag set, stopping mlx-hindsight-server" >> ${cfg.logDir}/watchdog.log
        kill "$SERVER_PID" 2>/dev/null
      ) &
      PAUSE_MON_PID=$!
      cleanup() {
        kill "$SERVER_PID" 2>/dev/null
        [ -n "''${TAIL_PID:-}" ] && kill "$TAIL_PID" 2>/dev/null
        [ -n "''${PAUSE_MON_PID:-}" ] && kill "$PAUSE_MON_PID" 2>/dev/null
      }
      trap cleanup EXIT INT TERM
      tail -n 0 -F ${cfg.logDir}/server.log 2>/dev/null | while read -r LINE; do
        case "$LINE" in
          *"generation thread died"*|*"Insufficient Memory"*|*"Command buffer execution failed"*)
            echo "$(date '+%F %T') generation thread died, restarting mlx-hindsight-server" >> ${cfg.logDir}/watchdog.log
            kill -9 "$SERVER_PID" 2>/dev/null
            ;;
        esac
      done &
      TAIL_PID=$!
      wait "$SERVER_PID"
      exit 0
    '';
    serviceConfig = {
      Label = "com.user.mlx-hindsight-server";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/server.log";
      StandardErrorPath = "${cfg.logDir}/server.log";
    };
  };

  # Canary watchdog, simpler than the 9B's: this server has ONE consumer
  # (the Hindsight daemon, LLM_TIMEOUT=600) and no proxy in front, so a
  # canary only queues behind the single in-flight retain (~40s; -m 180
  # covers it). 404/5xx = dead generation thread, restart at once. A
  # canary timeout can still be one orphaned thinking decode self-clearing
  # (~2-3 min), so require 3 consecutive timeouts (~22 min) before a
  # restart; a live retain never spans that.
  launchd.user.agents.mlx-hindsight-watchdog = {
    script = ''
      # While the local-models pause flag exists the server is gated off by
      # design; never restart into a pause.
      [ -f ${homeDirectory}/.local/state/local-models.paused ] && exit 0
      CODE=$(curl -s -o /dev/null -w '%{http_code}' -m 180 \
        http://127.0.0.1:${toString cfg.port}/v1/chat/completions \
        -H 'Content-Type: application/json' \
        -d '{"model":"${cfg.model}","max_tokens":1,"chat_template_kwargs":{"enable_thinking":false},"messages":[{"role":"user","content":"ping"}]}')
      if [ "$CODE" = "404" ] || [ "$CODE" -ge 500 ] 2>/dev/null; then
        echo "$(date '+%F %T') canary failed (HTTP $CODE), restarting mlx-hindsight-server" >> ${cfg.logDir}/watchdog.log
        launchctl kickstart -k gui/$(id -u)/com.user.mlx-hindsight-server
        rm -f ${cfg.logDir}/watchdog.stalled
      elif [ "$CODE" = "000" ]; then
        STALLED=${cfg.logDir}/watchdog.stalled
        N=$(( $(cat "$STALLED" 2>/dev/null || echo 0) + 1 ))
        echo "$N" > "$STALLED"
        if [ "$N" -ge 3 ]; then
          echo "$(date '+%F %T') sustained unresponsive ($N cycles), restarting mlx-hindsight-server" >> ${cfg.logDir}/watchdog.log
          rm -f "$STALLED"
          launchctl kickstart -k gui/$(id -u)/com.user.mlx-hindsight-server
        else
          echo "$(date '+%F %T') canary 000 (in-flight retain or short orphan decode), waiting ($N/3)" >> ${cfg.logDir}/watchdog.log
        fi
      else
        rm -f ${cfg.logDir}/watchdog.stalled
      fi
    '';
    serviceConfig = {
      Label = "com.user.mlx-hindsight-watchdog";
      RunAtLoad = false;
      StartInterval = 300;
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/watchdog.out";
      StandardErrorPath = "${cfg.logDir}/watchdog.out";
    };
  };

  environment.etc."newsyslog.d/mlx-hindsight.conf".text = ''
    # logfilename                           owner:group  mode  count  size  when  flags
    ${cfg.logDir}/server.log                ${user}:staff 644  ${toString cfg.maxArchives}  ${
      toString (cfg.maxLogSizeMB * 1024)
    }  *  J
  '';
}

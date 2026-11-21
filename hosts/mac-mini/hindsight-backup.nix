# Nightly backup of the Hindsight pg0 database (instance hindsight-embed-hermes).
#
# pg_dump from the pg0 installation into ~/.hindsight/backups, with the same
# rotation policy as the work Mac's ~/.hindsight/backup-hindsight.sh: keep the
# newest 10 hindsight-auto-* dumps, prune oldest past 1 GB total. Manual
# hindsight-manual-* dumps are never touched. A failed dump never triggers
# rotation, and a stopped pg0 is logged and skipped.
#
# pg0 runs the instance on 127.0.0.1:5432 (see ~/.pg0/instances/
# hindsight-embed-hermes/instance.json; port differs from the work Mac's 5433).
# The 03:30 slot keeps the backup off the evening window when the local models
# are in use; pg_dump is I/O-light and does not touch the GPUs.
{
  user,
  homeDirectory,
  pkgs,
  ...
}:

let
  backupScript = pkgs.writeShellScript "hindsight-backup" ''
    set -euo pipefail

    BACKUP_DIR="${homeDirectory}/.hindsight/backups"
    LOG_FILE="${homeDirectory}/.hindsight/logs/backup.log"
    PG_BIN="${homeDirectory}/.pg0/installation/18.1.0/bin"
    PG_HOST="127.0.0.1"
    PG_PORT="5432"
    PG_USER="hindsight"
    PG_DB="hindsight"
    MAX_COUNT=10
    MAX_SIZE_BYTES=1073741824  # 1 GB

    mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

    log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"; }

    # Skip if pg0 is not running — a skipped backup never triggers rotation.
    if ! "$PG_BIN/pg_isready" -h "$PG_HOST" -p "$PG_PORT" 2>/dev/null; then
      log "SKIP: pg0 not running on $PG_HOST:$PG_PORT"
      exit 0
    fi

    STAMP=$(date '+%Y%m%d-%H%M%S')
    DUMP_FILE="$BACKUP_DIR/hindsight-auto-''${STAMP}.dump"

    log "Starting dump -> $DUMP_FILE"
    if ! PGPASSWORD=hindsight "$PG_BIN/pg_dump" -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" -F c -f "$DUMP_FILE" 2>> "$LOG_FILE"; then
      log "FAIL: pg_dump failed, removing partial dump"
      rm -f "$DUMP_FILE"
      exit 1
    fi

    SIZE=$(stat -f%z "$DUMP_FILE" 2>/dev/null || echo 0)
    log "Dump OK: $(echo "$SIZE" | awk '{printf "%.1f MB", $1/1048576}')"

    # Rotation: keep newest MAX_COUNT, then prune by size up to MAX_SIZE_BYTES.
    # Only ever touches hindsight-auto-* files.
    cd "$BACKUP_DIR"
    auto_dumps=($(ls -1t hindsight-auto-*.dump 2>/dev/null || true))

    if (( ''${#auto_dumps[@]} > MAX_COUNT )); then
      for f in "''${auto_dumps[@]:$MAX_COUNT}"; do
        rm -f "$f"
        log "ROTATE (count): removed $f"
      done
      auto_dumps=("''${auto_dumps[@]:0:$MAX_COUNT}")
    fi

    total=0
    for f in "''${auto_dumps[@]}"; do
      total=$(( total + $(stat -f%z "$f" 2>/dev/null || echo 0) ))
    done

    if (( total > MAX_SIZE_BYTES )); then
      for (( i=''${#auto_dumps[@]}-1; i>=0; i-- )); do
        if (( total <= MAX_SIZE_BYTES )); then break; fi
        f="''${auto_dumps[$i]}"
        sz=$(stat -f%z "$f" 2>/dev/null || echo 0)
        rm -f "$f"
        total=$(( total - sz ))
        log "ROTATE (size): removed $f"
      done
    fi

    remaining=$(ls -1 hindsight-auto-*.dump 2>/dev/null | wc -l | tr -d ' ')
    log "Rotation done: $remaining auto backups remaining"
  '';
in
{
  launchd.user.agents.hindsight-backup = {
    script = ''
      exec ${backupScript}
    '';
    serviceConfig = {
      Label = "io.hindsight.backup-mini";
      RunAtLoad = false;
      StartCalendarInterval = {
        Hour = 3;
        Minute = 30;
      };
      ProcessType = "Background";
      StandardOutPath = "${homeDirectory}/.hindsight/logs/backup-launchd.out";
      StandardErrorPath = "${homeDirectory}/.hindsight/logs/backup-launchd.out";
    };
  };
}

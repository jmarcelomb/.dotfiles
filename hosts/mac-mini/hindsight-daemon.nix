# Hindsight memory daemon (profile `hermes`) as a launchd user agent.
# Replaces the stale hand-written io.hindsight.hermes plist that pointed at a
# dead Hermes venv path (hindsight-embed). The daemon now starts at login and
# restarts on crash, so Hermes/OpenCode memory no longer depends on manual
# nohup starts or on-demand plugin spawns.
#
# CRITICAL: HINDSIGHT_API_DATABASE_URL must be set — without it the daemon
# silently serves the EMPTY default pg0 instance `hindsight` instead of
# `hindsight-embed-hermes` (health checks still pass, wrong data).
{ user, homeDirectory, ... }:

let
  cfg = {
    port = 9177;
    logDir = "${homeDirectory}/.hindsight/profiles";
    envFile = "${homeDirectory}/.hindsight/profiles/hermes.env";
    version = "0.10.2";
    # uv from the nix profile; stable across Hermes updates
    uv = "/etc/profiles/per-user/${user}/bin/uv";
  };
in
{
  launchd.user.agents.hindsight-daemon = {
    script = ''
      export HINDSIGHT_API_DATABASE_URL="pg0://hindsight-embed-hermes"
      # hermes.env is dotenv format (JSON values), NOT shell-sourceable — parse it.
      set -a
      eval "$(/usr/bin/python3 - <<'PYEOF'
      import re, shlex
      for ln in open("${cfg.envFile}"):
          ln = ln.strip()
          if not ln or ln.startswith("#") or "=" not in ln:
              continue
          k, v = ln.split("=", 1)
          if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", k):
              continue
          if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
              v = v[1:-1]
          print("export %s=%s" % (k, shlex.quote(v)))
      PYEOF
      )"
      set +a
      exec ${cfg.uv} tool uvx hindsight-api@${cfg.version} --port ${toString cfg.port}
    '';
    serviceConfig = {
      Label = "io.hindsight.hermes";
      RunAtLoad = true;
      KeepAlive = true; # restart on crash
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/launchd.out.log";
      StandardErrorPath = "${cfg.logDir}/launchd.err.log";
    };
  };
}

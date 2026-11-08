{ pkgs, ... }:
{
  # Runs the renovate one-shot service (~/server/docker-compose.yml) once a
  # day instead of keeping a container alive on a sleep loop, so the host
  # container count stays minimal. `docker compose run --rm` creates a
  # temporary container that removes itself on exit.
  systemd.services.renovate = {
    description = "renovate dependency update bot (daily run)";
    after = [
      "docker.service"
      "network-online.target"
    ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/home/hinata/server";
      User = "hinata";
      Group = "users";
      ExecStart = "${pkgs.docker}/bin/docker compose run --rm renovate";
      TimeoutStartSec = 3600;
      SyslogIdentifier = "renovate";
    };
  };

  systemd.timers.renovate = {
    description = "Daily renovate run at 04:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Persistent=true catches up if the VM was suspended/down at 04:00.
      OnCalendar = "*-*-* 04:00:00";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
  };
}

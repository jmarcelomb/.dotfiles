{ pkgs, ... }:
{
  # Nightly backup of the Matrix homeserver (continuwuity, ~/server/matrix).
  #
  # The data dir is RocksDB; a live rsync can capture torn state, so the
  # container is stopped for the copy (a few seconds for a 2-user instance)
  # and always restarted afterwards, even if rsync fails. `docker stop`
  # marks the container as manually stopped, which bypasses the compose
  # restart policy - hence the explicit `docker start`.
  #
  # (The Fluxer nightly backup that used to live here died with Fluxer on
  # 2026-11-07; its backups are archived on the nas/fluxer TrueNAS dataset.)
  systemd.services.matrix-backup = {
    description = "Backup Matrix homeserver data to TrueNAS";
    wants = [ "network-online.target" ];
    # The automount unit name is derived from the mountpoint path
    # (/mnt/nfs-matrix); renaming the mountpoint breaks this ordering.
    after = [
      "network-online.target"
      "mnt-nfs\\x2dmatrix.automount"
      "docker.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "hinata";
      Group = "users";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker stop continuwuity; ${pkgs.rsync}/bin/rsync -a --delete /home/hinata/server/matrix/data/ /mnt/nfs-matrix/matrix/data/; ${pkgs.docker}/bin/docker start continuwuity'";
      SyslogIdentifier = "matrix-backup";
    };
  };

  systemd.timers.matrix-backup = {
    description = "Nightly Matrix backup to TrueNAS";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:15:00";
      # Run on next boot if the VM was off at the scheduled time.
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}

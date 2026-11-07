{ pkgs, ... }:
{
  # Nightly backup of the Fluxer instance.
  #
  # rexctl backup writes ONE restorable file (settings, database, uploads,
  # search data) into ~/fluxer/backups. Fluxer pauses briefly while uploads
  # are copied - acceptable for a personal instance at 04:00.
  #
  # The backups folder is then rsynced to the NFS share on TrueNAS (HDD
  # pool). Runs as hinata so NFS root-squash doesn't cause "Permission
  # denied" when creating files. rexctl keeps the last N backups in the
  # folder (set once via `rexctl backup keep 7`), and the rsync --delete
  # mirrors that window onto the HDD pool.
  systemd.services.fluxer-backup = {
    description = "Backup Fluxer instance and ship it to TrueNAS";
    wants = [ "network-online.target" ];
    # The automount unit name is derived from the mountpoint path
    # (/mnt/nfs-fluxer); renaming the mountpoint breaks this ordering.
    after = [
      "network-online.target"
      "mnt-nfs\\x2dfluxer.automount"
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "hinata";
      Group = "users";
      ExecStart = "/home/hinata/.local/bin/rexctl backup";
      ExecStartPost = "${pkgs.rsync}/bin/rsync -a --delete /home/hinata/fluxer/backups/ /mnt/nfs-fluxer/backups/";
      SyslogIdentifier = "fluxer-backup";
    };
  };

  systemd.timers.fluxer-backup = {
    description = "Nightly Fluxer backup to TrueNAS";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      # Run on next boot if the VM was off at the scheduled time.
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };

  # Nightly backup of the Matrix homeserver (continuwuity, ~/server/matrix).
  #
  # The data dir is RocksDB; a live rsync can capture torn state, so the
  # container is stopped for the copy (a few seconds for a 2-user instance)
  # and always restarted afterwards, even if rsync fails. `docker stop`
  # marks the container as manually stopped, which bypasses the compose
  # restart policy - hence the explicit `docker start`.
  systemd.services.matrix-backup = {
    description = "Backup Matrix homeserver data to TrueNAS";
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "mnt-nfs\\x2dfluxer.automount"
      "docker.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "hinata";
      Group = "users";
      ExecStart = "${pkgs.bash}/bin/bash -c 'docker stop continuwuity; ${pkgs.rsync}/bin/rsync -a --delete /home/hinata/server/matrix/data/ /mnt/nfs-fluxer/matrix/data/; docker start continuwuity'";
      SyslogIdentifier = "matrix-backup";
    };
  };

  systemd.timers.matrix-backup = {
    description = "Nightly Matrix backup to TrueNAS";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:15:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}

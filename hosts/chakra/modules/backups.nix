{ pkgs, ... }:
{
  # Nightly backup of docker volumes to the NFS share on TrueNAS.
  # Runs as `hinata` (not root) so that NFS root-squash on the TrueNAS side
  # doesn't cause "Permission denied" when creating files.
  systemd.services.docker-volumes-backup = {
    description = "Backup docker volumes to NFS share on TrueNAS";
    after = [ "network-online.target" "mnt-nfs\\x2dchakra.automount" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "hinata";
      Group = "users";
      ExecStart = "${pkgs.rsync}/bin/rsync -av --delete /home/hinata/server/volumes/ /mnt/nfs-chakra/docker-volumes-backup/";
      # Log output tagged so `journalctl -t docker-backup` still works.
      SyslogIdentifier = "docker-backup";
    };
  };

  systemd.timers.docker-volumes-backup = {
    description = "Nightly docker volumes backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      # Run on next boot if the VM was off at the scheduled time.
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };

  # Nightly rsync of ~/server to the mac-mini for offsite-ish redundancy.
  # Runs as root so it can read docker-managed volume files owned by
  # in-container UIDs. Still authenticates to mac-mini as `jmmb` using
  # hinata's dedicated backup key (locked down on the mac-mini side via
  # authorized_keys `command="..."` + `restrict` + `from="192.168.0.236"`).
  systemd.services.server-offsite-rsync = {
    description = "Mirror ~/server to mac-mini";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      # User = root (default) so we can read all docker volume files.
      # IdentitiesOnly=yes prevents ssh-agent from offering other keys.
      # StrictHostKeyChecking=accept-new so first run doesn't hang waiting
      # for interactive host-key confirmation.
      ExecStart = ''
        ${pkgs.rsync}/bin/rsync -az --delete \
          -e "${pkgs.openssh}/bin/ssh -i /home/hinata/.ssh/id_ed25519_backup -o IdentitiesOnly=yes -o UserKnownHostsFile=/home/hinata/.ssh/known_hosts -o StrictHostKeyChecking=accept-new -o BatchMode=yes" \
          /home/hinata/server/ jmmb@mac-mini.home:server/
      '';
      SyslogIdentifier = "server-offsite-rsync";
    };
  };

  systemd.timers.server-offsite-rsync = {
    description = "Nightly ~/server rsync to mac-mini";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 20:00:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}

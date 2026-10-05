{ pkgs, ... }:
{
  # Nightly push of caddy's stateful bits (Let's Encrypt certs + account
  # keys in volumes/caddy, WireGuard identity in volumes/netbird-client)
  # to chakra, landing inside chakra's ~/server/volumes tree so chakra's
  # existing backup timers carry them onward to the TrueNAS NFS share and
  # the mac-mini offsite copy. Total volume is a few MB.
  #
  # Runs as ROOT locally: the netbird-client volume contains root-owned
  # state (opendir as hinata -> Permission denied, seen 2026-10-05).
  # Remote side is unaffected: ssh targets hinata@chakra with the
  # dedicated backup key, so files land owned by hinata on chakra.
  systemd.services.caddy-state-backup = {
    description = "Push caddy/netbird state to chakra's backed-up tree";
    after = [
      "network-online.target"
      "docker.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.rsync}/bin/rsync -az --delete \
          -e "${pkgs.openssh}/bin/ssh -i /home/hinata/.ssh/id_ed25519_backup_to_chakra -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
          /home/hinata/server/caddy/volumes/ \
          hinata@chakra.home:/home/hinata/server/volumes/caddy-guest/
      '';
      SyslogIdentifier = "caddy-state-backup";
    };
  };

  systemd.timers.caddy-state-backup = {
    description = "Nightly caddy state push to chakra";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Ahead of chakra's 02:00 NFS backup of server/volumes.
      OnCalendar = "*-*-* 01:15:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}

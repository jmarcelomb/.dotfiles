{ pkgs, ... }:
{
  # Nightly push of caddy's stateful bits (Let's Encrypt certs + account
  # keys in volumes/caddy, WireGuard identity in volumes/netbird-client)
  # to chakra, landing inside chakra's ~/server/volumes tree so chakra's
  # existing backup timers carry them onward to the TrueNAS NFS share and
  # the mac-mini offsite copy. Total volume is a few MB.
  #
  # Without this, rebuilding the caddy VM would mean re-issuing all
  # *.p.marceloborges.dev certs (rate-limited) and re-enrolling the
  # netbird client.
  systemd.services.caddy-state-backup = {
    description = "Push caddy/netbird state to chakra's backed-up tree";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "hinata";
      Group = "users";
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

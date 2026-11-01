# Starts the rexctl-managed Fluxer instance at boot.
#
# rexctl's own autostart (doctor --fix) can't work for a non-root instance
# even with lingering enabled, so boot bring-up is a plain NixOS oneshot
# running `rexctl start` as hinata. Idempotent: no-op when already running.
# Restarting this service is also the manual "bounce Fluxer" lever.
{
  ...
}:
{
  systemd.services.fluxer-instance = {
    description = "Fluxer instance (rexctl-managed, /home/hinata/fluxer)";
    after = [
      "docker.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "hinata";
      Group = "users";
      RemainAfterExit = true;
      TimeoutStartSec = "10min";
      ExecStart = "/home/hinata/.local/bin/rexctl start -y --dir /home/hinata/fluxer";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

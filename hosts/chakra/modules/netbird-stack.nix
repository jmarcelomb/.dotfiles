{ pkgs, ... }:
{
  # Manages the netbird docker compose stack (traefik, dashboard, netbird
  # server, reverse-proxy, crowdsec) as a systemd unit instead of relying on
  # docker's own `restart: unless-stopped` policy, which doesn't respect
  # compose `depends_on` ordering on daemon/VM boot.
  systemd.services.netbird-compose = {
    description = "netbird docker compose stack (/home/hinata/server/netbird)";
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/hinata/server/netbird";
      User = "hinata";
      Group = "users";
      # Tear down whatever docker's `restart: unless-stopped` policy
      # auto-restored on daemon boot (that restore ignores compose
      # `depends_on` ordering), then bring the stack back up under compose
      # control for a clean, ordered start.
      ExecStartPre = "${pkgs.docker}/bin/docker compose down";
      ExecStart = "${pkgs.docker}/bin/docker compose up -d --remove-orphans";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
      TimeoutStartSec = 300;
      SyslogIdentifier = "netbird-compose";
    };
  };
}

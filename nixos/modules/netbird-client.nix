{ pkgs, ... }:
{
  # NetBird client daemon: joins the mesh served by chakra's netbird
  # server stack. Import this on any host that should be a mesh peer,
  # then register once (interactive; setup keys stay out of this public
  # repo):
  #   sudo netbird up --management-url https://<mgmt-domain> --setup-key <KEY>
  # Daemon state (WireGuard identity) persists in /var/lib/netbird.
  #
  # Host-specific tuning (firewall trust for wt0, extra systemd ordering)
  # goes in the importing host's config; use services.netbird.ui.enable
  # on GUI hosts for the tray app.
  services.netbird.enable = true;

  # CLI for `netbird status` / `netbird up`.
  environment.systemPackages = [ pkgs.netbird ];
}

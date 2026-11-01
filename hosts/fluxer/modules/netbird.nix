# NetBird client: native NixOS daemon (unlike chakra/caddy which run the
# docker container). Joins the mesh so the NetBird reverse proxy can target
# this VM as a peer for the public fluxer.marceloborges.dev service.
#
# Enrolled once with a setup key (services.netbird.clients.fluxer.login);
# the identity persists in /var/lib/netbird-fluxer, so no key is kept on
# disk. To re-enroll from scratch, temporarily re-add
# `login.enable = true; login.setupKeyFile = <path>;` with a fresh key.
{
  ...
}:
{
  services.netbird.clients.fluxer = {
    port = 51820;
    environment = {
      NB_MANAGEMENT_URL = "https://netbird.marceloborges.dev";
      NB_HOSTNAME = "fluxer";
    };
  };

  # nixpkgs quirk: the login unit is emitted even with login.enable unset
  # (and is broken without a setup key file). The daemon connects from its
  # persisted identity, so the login unit is not needed at all.
  systemd.services."netbird-fluxer-login".enable = false;
}

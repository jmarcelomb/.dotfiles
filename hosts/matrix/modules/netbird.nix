# NetBird client: native NixOS daemon (unlike chakra/caddy which run the
# docker container). Joins the mesh so the NetBird reverse proxy can target
# this VM as a peer for the public matrix.marceloborges.dev service.
#
# Enrolled once with a setup key (2026-11-01, as the "fluxer" peer); the
# identity persists in /var/lib/netbird-fluxer, so no key is kept on disk.
# The client key below deliberately STAYS "fluxer": renaming it would change
# the state dir (/var/lib/netbird-matrix) and lose the enrollment, forcing a
# re-enroll with a fresh setup key. Only the reported hostname changed to
# "matrix" so a future re-enroll would register under the right name.
# To re-enroll from scratch, temporarily re-add
# `login.enable = true; login.setupKeyFile = <path>;` with a fresh key.
{
  ...
}:
{
  services.netbird.clients.fluxer = {
    port = 51820;
    environment = {
      NB_MANAGEMENT_URL = "https://netbird.marceloborges.dev";
      NB_HOSTNAME = "matrix";
    };
  };

  # nixpkgs quirk: the login unit is emitted even with login.enable unset
  # (and is broken without a setup key file). The daemon connects from its
  # persisted identity, so the login unit is not needed at all.
  systemd.services."netbird-fluxer-login".enable = false;
}

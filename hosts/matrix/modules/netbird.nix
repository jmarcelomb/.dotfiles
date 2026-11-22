# NetBird client: native NixOS daemon (unlike chakra/caddy which run the
# docker container). Joins the mesh so the NetBird reverse proxy can target
# this VM as a peer for the public matrix.marceloborges.dev service.
#
# Enrolled once with a setup key (2026-11-01, as the "fluxer" peer); the
# identity lives in /var/lib/netbird-matrix, so no key is kept on disk. The
# client was called "fluxer" until 2026-11-22 (the VM's old name); the state
# dir was moved across so the same peer identity (100.106.183.177) survives.
# Renaming the key again means moving the state dir with it, otherwise the
# daemon starts without a key and the peer disappears from the mesh.
# To re-enroll from scratch, temporarily re-add
# `login.enable = true; login.setupKeyFile = <path>;` with a fresh key.
{
  ...
}:
{
  services.netbird.clients.matrix = {
    port = 51820;
    environment = {
      NB_MANAGEMENT_URL = "https://netbird.marceloborges.dev";
      NB_HOSTNAME = "matrix";
    };
  };

  # nixpkgs quirk: the login unit is emitted even with login.enable unset
  # (and is broken without a setup key file). The daemon connects from its
  # persisted identity, so the login unit is not needed at all.
  systemd.services."netbird-matrix-login".enable = false;
}

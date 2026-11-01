# NetBird client: native NixOS daemon (unlike chakra/caddy which run the
# docker container). Joins the mesh so the NetBird reverse proxy can target
# this VM as a peer for the public fluxer.marceloborges.dev service.
#
# login.setupKeyFile is consumed once at first enrollment (LoadCredential);
# after the peer is enrolled the key can be deleted from that path.
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
    login.enable = true;
    login.setupKeyFile = "/home/hinata/netbird-setup-key";
  };
}

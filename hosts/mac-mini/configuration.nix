# Mac Mini - macOS system
{
  self,
  pkgs,
  user,
  homeDirectory,
  system,
  hostname,
  ...
}:
{
  imports = [
    ../../nix-darwin/profiles/base.nix
    ./vm-clipboard-sync.nix
    ./mlx-lm-server.nix
    ./mlx-lm-priority-proxy.nix
    ./mlx-vision-ondemand.nix
    # Dedicated Hindsight extraction server (gemma-4-e2b-it-4bit, :8085)
    ./mlx-hindsight-server.nix
    # LAN bridge exposing the local-models pause state to HA (:8086)
    ./mlx-local-models-bridge.nix
    # Remote dashboard on the NetBird IP (phone app / browser extension)
    ./hermes-dashboard.nix
    # Firecrawl Local (:3002) local web_extract backend, no cloud key
    ./firecrawl-local.nix
    # Hindsight memory daemon (profile hermes, pg0 hindsight-embed-hermes)
    ./hindsight-daemon.nix
    # Hindsight control plane web UI (:19177), loopback only
    ./hindsight-control-plane.nix
    # Nightly pg_dump of the Hindsight pg0 DB (03:30, rotate 10 / 1GB)
    ./hindsight-backup.nix
    # Google Workspace CLI (gws) - admin tooling
    ./googleworkspace.cli.nix
    # Jellyfin media server (native build: VideoToolbox transcoding; media
    # over NFS from the TrueNAS pool)
    ./jellyfin.nix
  ];

  # Host-specific configuration
  # (Most config comes from nix-darwin/profiles/base.nix)
}

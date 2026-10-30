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
    # Hindsight memory daemon (profile hermes, pg0 hindsight-embed-hermes)
    ./hindsight-daemon.nix
    # Google Workspace CLI (gws) - admin tooling
    ./googleworkspace.cli.nix
  ];

  # Host-specific configuration
  # (Most config comes from nix-darwin/profiles/base.nix)
}

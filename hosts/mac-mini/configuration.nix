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
    # mlx-lm local inference server (gemma-4-12B qat)
    ./mlx-lm-server.nix
    ./mlx-lm-priority-proxy.nix
    ./mlx-vision-ondemand.nix
    # Hindsight memory daemon (profile hermes, pg0 hindsight-embed-hermes)
    ./hindsight-daemon.nix
    # Google Workspace CLI (gws) - admin tooling
    ./googleworkspace.cli.nix
  ];

  # Host-specific configuration
  # (Most config comes from nix-darwin/profiles/base.nix)
}

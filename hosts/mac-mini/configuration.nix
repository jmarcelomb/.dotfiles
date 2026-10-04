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
  ];

  # Host-specific configuration
  # (Most config comes from nix-darwin/profiles/base.nix)
}

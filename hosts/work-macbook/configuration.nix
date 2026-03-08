# Work MacBook - macOS system
{ self, pkgs, user, homeDirectory, system, hostname, ... }:
{
  imports = [
    (import ../../nix-darwin/profiles/base.nix {
      inherit self pkgs user homeDirectory system hostname;
    })
    ./local-packages.nix
  ];

  # Host-specific configuration
  # (Most config comes from nix-darwin/profiles/base.nix)
}

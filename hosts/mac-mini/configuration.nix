# Mac Mini - macOS system
{ self, pkgs, user, homeDirectory, system, hostname, ... }:
{
  imports = [
    (import ../../nix-darwin/profiles/base.nix {
      inherit self pkgs user homeDirectory system hostname;
    })
    (import ./vm-clipboard-sync.nix { inherit user homeDirectory; })
  ];

  # Host-specific configuration
  # (Most config comes from nix-darwin/profiles/base.nix)
}

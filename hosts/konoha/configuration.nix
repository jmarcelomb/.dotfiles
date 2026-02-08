# Konoha - VMware VM Desktop system
{ pkgs, stateVersion, hostname, user, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../nixos/hardware/bootloader.nix
    ../../nixos/hardware/vmware-guest.nix

    # Profiles
    ../../nixos/profiles/base.nix
    ../../nixos/profiles/desktop.nix

    # Additional modules
    ../../nixos/modules/home-manager.nix
    ../../nixos/modules/net.nix
    ../../nixos/modules/nix.nix
    ../../nixos/modules/timezone.nix
    ../../nixos/modules/boot.nix
  ];

  # Host-specific configuration
  # (Most config comes from profiles above)
  # VMware-specific settings are in hardware/vmware-guest.nix
}

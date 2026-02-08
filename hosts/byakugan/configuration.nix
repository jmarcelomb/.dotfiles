# Byakugan - Desktop NixOS system
{ pkgs, stateVersion, hostname, user, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../nixos/hardware/bootloader.nix
    ../../nixos/hardware/nfs-client.nix  # Just enable NFS support, no mounts

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

  # Optional: Add NFS mounts if needed
  # fileSystems."/mnt/media" = {
  #   device = "nas.local:/media";
  #   fsType = "nfs";
  #   options = [ "nfsvers=4" "rw" "soft" "intr" ];
  # };
}

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
    ../../nixos/modules/cad.nix
  ];

  # Host-specific configuration
  # (Most config comes from profiles above)

  # Optional: Add NFS mounts if needed
  # fileSystems."/mnt/media" = {
  #   device = "nas.local:/media";
  #   fsType = "nfs";
  #   options = [ "nfsvers=4" "rw" "soft" "intr" ];
  # };

  # NVIDIA proprietary driver with PRIME support
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:3:0:0";
    };
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false; # Use proprietary driver
  };
}

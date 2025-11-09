{ pkgs, stateVersion, hostname, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix
    # ../../nixos/modules/bluetooth.nix
    ../../nixos/modules/audio.nix
    ../../nixos/modules/docker.nix
    ../../nixos/modules/env.nix
    ../../nixos/modules/net.nix
    ../../nixos/modules/nix.nix
    ../../nixos/modules/timezone.nix
    ../../nixos/modules/user.nix

    ./modules/cron.nix
    #(import ./modules/auto-upgrade.nix { inherit inputs; })
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  networking.hostName = hostname;
  system.stateVersion = stateVersion;
  services.openssh.enable = true;

  # NFS client support
  services.rpcbind.enable = true;
  
  # Mount NFS share from TrueNAS server for backups
  fileSystems."/mnt/nas/chakra" = {
    device = "truenas.home:/mnt/nas/chakra";
    fsType = "nfs";
    options = [ "nfsvers=4" "rw" "soft" "intr" ];
  };
}

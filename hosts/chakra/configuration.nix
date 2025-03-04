{ pkgs, stateVersion, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix
    ../../nixos/modules/bluetooth.nix
    ../../nixos/modules/audio.nix
    ../../nixos/modules/docker.nix
    ../../nixos/modules/env.nix
    ../../nixos/modules/net.nix
    ../../nixos/modules/nix.nix
    ../../nixos/modules/timezone.nix
    ../../nixos/modules/user.nix

    ./modules/cron.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = hostname;
  system.stateVersion = stateVersion;
  services.openssh.enable = true;
}


{ pkgs, stateVersion, hostname, inputs, ... }:

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
    (import ./modules/auto-upgrade.nix { inherit inputs; })
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = hostname;
  system.stateVersion = stateVersion;
  services.openssh.enable = true;
}

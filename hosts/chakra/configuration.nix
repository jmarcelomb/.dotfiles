{ pkgs, stateVersion, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix
    ../../nixos/modules/bluetooth.nix
    ../../nixos/modules/boot.nix
    ../../nixos/modules/audio.nix
    ../../nixos/modules/docker.nix
    ../../nixos/modules/env.nix
    ../../nixos/modules/net.nix
    ../../nixos/modules/nix.nix
    ../../nixos/modules/timezone.nix
    ../../nixos/modules/user.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = stateVersion;
  services.openssh.enable = true;

  # users.users.serveradmin = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Grant sudo access
  #   openssh.authorizedKeys.keys = [
  #     "your-ssh-public-key-here"
  #   ];
  # };

  # # Example: Enable a web server
  # services.nginx = {
  #   enable = true;
  #   virtualHosts."example.com" = {
  #     root = "/var/www";
  #     locations."/" = {
  #       index = "index.html";
  #     };
  #   };
  # };
}


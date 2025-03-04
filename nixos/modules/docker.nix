{ pkgs, lib, ... }:
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = lib.mkDefault true;

  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # users.users.serveradmin = {
  #   extraGroups = [ "docker" ];
  # };
}


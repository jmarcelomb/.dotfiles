{ pkgs, lib, ... }:
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = lib.mkDefault true;

    # Weekly cleanup of unused images, networks, and stopped containers.
    # Volumes are intentionally left alone to avoid data loss.
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}

# Base nix-darwin profile for all macOS hosts
# Consolidates common Darwin configuration to reduce duplication
{ self, pkgs, user, homeDirectory, system, hostname, ... }:
let
  sharedEnv = import ../../hosts/shared-env.nix { inherit pkgs; };
in
{
  imports = [
    ../system.nix
    ../homebrew.nix
    ../aerospace.nix
    ../../nixos/modules/gpg.nix  # GPG configuration works on both platforms
  ];

  # Nix settings
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;

  # Weekly GC so the store does not grow unbounded on long-lived macs.
  # Same retention as the NixOS hosts (14d) for consistency.
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 12; Minute = 0; };
    options = "--delete-older-than 14d";
  };

  # Platform configuration
  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  # Environment variables from shared config
  environment.variables = sharedEnv.systemVariables;

  # Host identification
  networking.hostName = hostname;
  system.primaryUser = user;

  # Services
  services.sketchybar.enable = true;

  # Shell
  programs.fish.enable = true;

  # User configuration
  users.users.${user} = {
    name = user;
    home = homeDirectory;
    shell = pkgs.fish;
  };
}

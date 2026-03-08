# Base nix-darwin profile for all macOS hosts
# Consolidates common Darwin configuration to reduce duplication
{ self, pkgs, user, homeDirectory, system, hostname }:
let
  sharedEnv = import ../../hosts/shared-env.nix { inherit pkgs; };
in
{
  imports = [
    (import ../system.nix { inherit self homeDirectory; })
    ../homebrew.nix
    ../aerospace.nix
    ../../nixos/modules/gpg.nix  # GPG configuration works on both platforms
  ];

  # Nix settings
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;

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

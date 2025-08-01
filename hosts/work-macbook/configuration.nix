{ self, pkgs, nixpkgs, user, homeStateVersion, hostname, homeDirectory, system, ... }:
let
  sharedEnv = import ../shared-env.nix { inherit pkgs; };
in
{
  imports = [
    (import ../../nix-darwin/system.nix { inherit self homeDirectory; })
    ../../nix-darwin/homebrew.nix
    ../../nix-darwin/aerospace.nix
    ../../nixos/modules/gpg.nix
    ./local-packages.nix
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  environment.variables = sharedEnv.systemVariables;

  networking.hostName = hostname;
  system.primaryUser = user;

  services.sketchybar.enable = true;
  programs.fish.enable = true;

  users.users.${user} = {
    name = user;
    home = homeDirectory;
    shell = pkgs.fish;
  };
}

{
  description = "Nix-Darwin configuration for MacOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    system = "aarch64-darwin";
    username = "jmmb";
    homeDirectory = "/Users/${username}";

    configuration = { pkgs, ... }: {
      # System settings
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;

      nixpkgs.hostPlatform = system;
      nixpkgs.config.allowUnfree = true;
      # User configuration
      users.users.${username} = {
        name = username;
        home = homeDirectory;
        shell = pkgs.fish;
      };

      # Shell configuration
      programs.fish.enable = true;
      services.sketchybar.enable = true;

      # Basic packages
      # environment.systemPackages = with pkgs; [
      #   vim
      # ];

      imports = [
        ./homebrew.nix
        (import ./system.nix { inherit pkgs self homeDirectory; })
        ./aerospace.nix
      ];
    };

    homeManagerConfiguration = { pkgs, ... }: let
      common_pkgs = import ../../home-manager/common-home-packages.nix { inherit pkgs; };
    in {
      home.username = username;
      home.homeDirectory = homeDirectory;
      home.stateVersion = "24.11";

      home.packages = common_pkgs.home.packages ++ (with pkgs; [
        neovim
        bat
        spotify
        kitty
      ]);

      imports = [
        ../../home-manager/modules/eza.nix
        ../../home-manager/modules/fonts.nix
        ../../home-manager/modules/starship.nix
      ];

      programs.home-manager.enable = true;
    };
  in {
    darwinConfigurations."mac-mini" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = homeManagerConfiguration;
        }
      ];
    };
  };
}

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
   rust-overlay = {
     url = "github:oxalica/rust-overlay";
     inputs.nixpkgs.follows = "nixpkgs";
   };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, rust-overlay }:
  let
    system = "aarch64-darwin";
    username = "jmmb";
    homeDirectory = "/Users/${username}";
    overlays = [ rust-overlay.overlays.default ];

    configuration = { pkgs, ... }: {
      # System settings
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;

      nixpkgs.hostPlatform = system;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = overlays;
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
      isDarwin = pkgs.stdenv.isDarwin;
      common_pkgs = import ../../home-manager/common-home-packages.nix { inherit pkgs; };
    in {
      home.username = username;
      home.homeDirectory = homeDirectory;
      home.stateVersion = "24.11";
      nixpkgs.overlays = overlays;

      home.packages = common_pkgs.home.packages ++ (with pkgs; [
        neovim
        bat
        kitty
      ]);

      home.sessionVariables = {
        LANG = "en_US.UTF-8";
        LC_CTYPE = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        EDITOR = "nvim";
      } // (
        if isDarwin then {
          # See: https://github.com/NixOS/nixpkgs/issues/390751
          DISPLAY = "nixpkgs-390751";
        } else {}
      );

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

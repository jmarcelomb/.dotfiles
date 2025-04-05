{
  description = "Nix-Darwin configuration for mac-mini";

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
    userfullname = "jmarcelomb";
    homeDirectory = "/Users/${username}";

    configuration = { pkgs, ... }: {
      # System settings
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.hostPlatform = system;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;

      # User configuration
      users.users.${username} = {
        name = username;
        home = homeDirectory;
      };

      # System defaults
      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        loginwindow.LoginwindowText = userfullname;
        screencapture.location = "${homeDirectory}/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Shell configuration
      # programs.zsh.enable = true;
      programs.fish.enable = true;

      # Basic packages
      # environment.systemPackages = with pkgs; [
      #   vim
      # ];
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

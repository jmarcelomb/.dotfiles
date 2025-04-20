{
  description = "Unified system configuration for nix-darwin, chakra, and konoha";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, rust-overlay, nix-darwin, ... }@inputs:
    let
      homeStateVersion = "24.11";

      # Function to create nix-darwin configurations
      makeDarwinSystem = { hostname, user, homeDirectory, system }:
        let
          overlays = [ rust-overlay.overlays.default ];
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit rust-overlay; };
          modules = [
            (import ./hosts/${hostname}/configuration.nix {
              inherit pkgs nixpkgs self hostname homeStateVersion user homeDirectory system;
            })
            home-manager.darwinModules.home-manager {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [{
                nixpkgs.overlays = overlays;
              }];

              home-manager.users.${user} = import ./home-manager/home.nix {
                inherit pkgs user homeDirectory homeStateVersion;
              };
            }
          ];
        };

      # Function to create NixOS configurations
      makeNixosSystem = { hostname, user, homeDirectory, stateVersion, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs stateVersion hostname user homeDirectory; };
          modules = [ ./hosts/${hostname}/configuration.nix ];
        };

    in {
      nixosConfigurations = {
        konoha = makeNixosSystem {
          hostname = "konoha";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "24.11";
          system = "aarch64-linux";
        };
        chakra = makeNixosSystem {
          hostname = "chakra";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "24.11";
          system = "x86_64-linux";
        };
      };

      darwinConfigurations = {
        "mac-mini" = makeDarwinSystem {
          hostname = "mac-mini";
          user = "jmmb";
          homeDirectory = "/Users/jmmb";
          system = "aarch64-darwin";
        };

        "work-macbook" = makeDarwinSystem {
          hostname = "work-macbook";
          user = "jmmb";
          homeDirectory = "/Users/jmmb";
          system = "aarch64-darwin";
        };
      };
    };
}

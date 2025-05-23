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

      # Shared overlays
      overlays = [ rust-overlay.overlays.default ];

      # Function to create nix-darwin configurations
      makeDarwinSystem = { hostname, user, isServer, homeDirectory, system }:
        let
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
                inherit pkgs user homeDirectory homeStateVersion isServer;
              };
            }
          ];
        };

      # Function to create NixOS configurations
      makeNixosSystem = { hostname, user, isServer, homeDirectory, stateVersion, system }:
        let
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs stateVersion hostname user homeDirectory isServer; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [{
                nixpkgs.overlays = overlays;
              }];
              home-manager.users.${user} = import ./home-manager/home.nix {
                inherit pkgs user homeDirectory homeStateVersion isServer;
              };
            }
          ];
        };

      # Define supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Function to generate attributes for all supported systems
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in {
      nixosConfigurations = {
        konoha = makeNixosSystem {
          hostname = "konoha";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "24.11";
          system = "aarch64-linux";
          isServer = false;
        };
        chakra = makeNixosSystem {
          hostname = "chakra";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "24.11";
          system = "x86_64-linux";
          isServer = true;
        };
      };

      darwinConfigurations = {
        "mac-mini" = makeDarwinSystem {
          hostname = "mac-mini";
          user = "jmmb";
          homeDirectory = "/Users/jmmb";
          system = "aarch64-darwin";
          isServer = false;
        };

        "work-macbook" = makeDarwinSystem {
          hostname = "work-macbook";
          user = "jmmb";
          homeDirectory = "/Users/jmmb";
          system = "aarch64-darwin";
          isServer = false;
        };
      };

      # Add formatters for all supported systems
      formatter = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in pkgs.nixpkgs-fmt);
    };
}

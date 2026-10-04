{
  description = "Unified system configuration for nix-darwin and NixOS hosts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      rust-overlay,
      nix-darwin,
      zen-browser,
      ...
    }@inputs:
    let
      homeStateVersion = "26.05";

      # Shared overlays, applied once via nixpkgs.overlays so every host -
      # system and home-manager alike - evaluates a single pkgs instance
      # (home-manager.useGlobalPkgs = true below).
      overlays = [
        rust-overlay.overlays.default
        # Skip heavyweight test suites on packages we override anyway:
        # any .override* is a cache.nixos.org miss, so tests would re-run
        # on every host that builds the package (ffmpeg-full's FATE suite
        # alone can grind for hours on the server VMs).
        (
          final: prev:
          {
            ffmpeg-full = prev.ffmpeg-full.overrideAttrs (_: {
              doCheck = false;
            });
          }
          // prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
            direnv = prev.direnv.overrideAttrs (_: {
              doCheck = false;
            });
          }
        )
      ];

      # Single source of truth for nixpkgs configuration per host.
      nixpkgsModule = {
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
      };

      # Shared home-manager wiring. One pkgs instance (useGlobalPkgs), same
      # collision behavior on every host (backupFileExtension). This is a
      # function module: `pkgs` here is the outer system's module pkgs, so
      # home.nix receives the very same instance home-manager uses.
      homeManagerModule =
        {
          user,
          homeDirectory,
          isServer,
        }:
        { pkgs, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.${user} = import ./home-manager/home.nix {
            inherit
              pkgs
              user
              homeDirectory
              homeStateVersion
              isServer
              ;
          };
        };

      # Args every host module (and the profiles they import) can expect.
      specialArgsFor =
        {
          user,
          homeDirectory,
          system,
          hostname,
          isServer,
        }:
        {
          inherit
            self
            inputs
            user
            homeDirectory
            system
            hostname
            isServer
            homeStateVersion
            ;
        };

      makeDarwinSystem =
        {
          hostname,
          user,
          isServer,
          homeDirectory,
          system,
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = specialArgsFor {
            inherit
              user
              homeDirectory
              system
              hostname
              isServer
              ;
          };
          modules = [
            nixpkgsModule
            ./hosts/${hostname}/configuration.nix
            home-manager.darwinModules.home-manager
            (homeManagerModule { inherit user homeDirectory isServer; })
          ];
        };

      makeNixosSystem =
        {
          hostname,
          user,
          isServer,
          homeDirectory,
          stateVersion,
          system,
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs =
            (specialArgsFor {
              inherit
                user
                homeDirectory
                system
                hostname
                isServer
                ;
            })
            // {
              inherit stateVersion;
            };
          modules = [
            nixpkgsModule
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            (homeManagerModule { inherit user homeDirectory isServer; })
          ];
        };

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in
    {
      nixosConfigurations = {
        konoha = makeNixosSystem {
          hostname = "konoha";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "26.05";
          system = "aarch64-linux";
          isServer = false;
        };
        chakra = makeNixosSystem {
          hostname = "chakra";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "26.05";
          system = "x86_64-linux";
          isServer = true;
        };
        caddy = makeNixosSystem {
          hostname = "caddy";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "26.05";
          system = "x86_64-linux";
          isServer = true;
        };
        byakugan = makeNixosSystem {
          hostname = "byakugan";
          user = "hinata";
          homeDirectory = "/home/hinata";
          stateVersion = "26.05";
          system = "x86_64-linux";
          isServer = false;
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
      };

      # nixfmt-tree: upstream's wrapper for formatting directories
      # (nixpkgs-fmt is archived; bare nixfmt over trees is deprecated).
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}

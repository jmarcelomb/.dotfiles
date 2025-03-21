{
  description = "My system configuration";

  inputs = {
    # Default to the nixos-unstable branch
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Latest stable branch of nixpkgs, used for version rollback
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Use the master branch of home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:
    let
      homeStateVersion = "24.11";
      user = "hinata";
      hosts = [
        {
          hostname = "konoha";
          stateVersion = "24.11";
          system = "aarch64-linux";
        }
        {
          hostname = "chakra";
          stateVersion = "24.11";
          system = "x86_64-linux";
        }
      ];

      makeSystem = { hostname, stateVersion, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs stateVersion hostname user;
            pkgs-stable = import nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
          };

          modules = [ ./hosts/${hostname}/configuration.nix ];
        };

    in {
      nixosConfigurations = nixpkgs.lib.foldl' (configs: host:
        configs // {
          "${host.hostname}" = makeSystem {
            inherit (host) hostname stateVersion system;
          };
        }
      ) { } hosts;

      homeConfigurations = nixpkgs.lib.foldl' (configs: host:
        configs // {
          "${host.hostname}" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${host.system};
            extraSpecialArgs = { inherit inputs homeStateVersion user; };

            modules = [ ./home-manager/home.nix ];
          };
        }
      ) { } hosts;

      # Define a formatter for nix fmt
      formatter = nixpkgs.lib.foldl' (configs: host:
        configs // {
          "${host.system}" = nixpkgs.legacyPackages.${host.system}.nixpkgs-fmt;
        }
      ) { } hosts;
    };
}

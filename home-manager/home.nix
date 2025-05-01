{ pkgs, isServer, homeStateVersion, user, homeDirectory, ... }:
let
  sharedEnv = import ../hosts/shared-env.nix { inherit pkgs; };
  inherit (pkgs.stdenv) isDarwin;
in
{
  imports = [
    ./modules/default.nix
    (if isDarwin
     then import ./common-home-packages.nix { inherit pkgs isServer; }
     else import ./linux-home-packages.nix { inherit pkgs isServer; })
  ];

  home = {
    username = user;
    inherit homeDirectory;
    stateVersion = homeStateVersion;
    sessionVariables = sharedEnv.userVariables;
  };
  programs.home-manager.enable = true;
}

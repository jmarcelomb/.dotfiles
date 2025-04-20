{ pkgs, homeStateVersion, user, homeDirectory, ... }:
let
  sharedEnv = import ../hosts/shared-env.nix { inherit pkgs; };
  inherit (pkgs.stdenv) isDarwin;
in
{
  imports = [
    ./modules/default.nix
    (if isDarwin then ./common-home-packages.nix else ./linux-home-packages.nix { inherit pkgs; })
  ];

  home = {
    username = user;
    inherit homeDirectory;
    stateVersion = homeStateVersion;
    sessionVariables = sharedEnv.userVariables;
  };
  programs.home-manager.enable = true;
}

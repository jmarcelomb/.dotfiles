{ pkgs, ... }:
let
  sharedEnv = import ../shared-env.nix { inherit nixpkgs; };
in
{
  environment.sessionVariables = sharedEnv.systemVariables;
}
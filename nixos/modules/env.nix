{ pkgs, ... }:
let
  sharedEnv = import ../../hosts/shared-env.nix { inherit pkgs; };
in
{
  environment.sessionVariables = sharedEnv.systemVariables;
}

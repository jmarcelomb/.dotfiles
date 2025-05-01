{ pkgs, isServer, ... }:

let
  common = import ./common-home-packages.nix { inherit pkgs isServer; };
in {
  home.packages = common.home.packages ++ (with pkgs; [
    wl-clipboard
  ]);
}

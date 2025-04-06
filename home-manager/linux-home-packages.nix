{ pkgs, ... }:

let
  common = import ./common-home-packages.nix { inherit pkgs; };
in {
  home.packages = common.home.packages ++ (with pkgs; [
    ghostty
    kitty
    wl-clipboard
  ]);
}


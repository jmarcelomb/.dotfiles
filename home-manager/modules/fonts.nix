{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  config = lib.mkIf (!isDarwin) {
    fonts.fontconfig.enable = true;
    home.packages = [
      pkgs.nerd-fonts.sauce-code-pro
    ];
  };
}

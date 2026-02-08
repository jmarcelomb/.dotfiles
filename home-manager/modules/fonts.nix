{ pkgs, lib, ... }:
{
  # Define the font name as a variable that can be reused
  _module.args.nerdFontName = "SauceCodePro Nerd Font";

  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.nerd-fonts.sauce-code-pro
  ];
}

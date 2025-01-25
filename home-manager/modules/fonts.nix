{ pkgs, ... }: {
  fonts.packages = with pkgs; [
  (nerdfonts.override { fonts = [ "Source Code Pro"  ]; })
    jetbrains-mono
  ];
}

{
  programs.lazygit = {
    enable = true;
    settings = {
      gui.showIcons = true;
      gui.theme = {
        lightTheme = false;
        activeBorderColor = [ "green" "bold" ];
        inactiveBorderColor = [ "grey" ];
        selectedLineBgColor = [ "blue" ];
      };
    };
  };
}

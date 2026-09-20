{
  homebrew = {
    enable = true; # Homebrew needs to be installed on its own!
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    brews = [
      "imagemagick"
      "gh"
    ];
    casks = [
      "veracrypt"
      "keycastr"
      "obs"
      "raycast"

      "font-sketchybar-app-font"
      "font-sauce-code-pro-nerd-font"
      "sf-symbols"

      # "discord"
      "element"
      "whatsapp"
      "messenger"
      "telegram"
      "spotify"

      "shottr"
      "orbstack"
      "joplin"
      "chatgpt"

      "google-chrome"

      "ghostty"

      "inkscape"

      "vlc"

      "transmission"
    ];
  };
}

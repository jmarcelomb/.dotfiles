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
    ];
    casks = [
      "veracrypt"
      "keycastr"
      "obs"
      "raycast"

      "font-sketchybar-app-font"
      "sf-symbols"

      # "discord"
      "element"
      "whatsapp"
      "messenger"
      "telegram"
      "spotify"

      "shottr"
      "docker-desktop"
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

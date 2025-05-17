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
      "podman"
    ];
    casks = [
      "keycastr"
      "obs"
      "raycast"

      "font-sketchybar-app-font"
      "sf-symbols"

      "discord"
      "whatsapp"
      "messenger"
      "spotify"

      "shottr"
      "podman-desktop"
      "joplin"
      "chatgpt"

      "google-chrome"
      "zen-browser"

      "ghostty"

      "bambu-studio"
      "insta360-studio"

      "vlc"
    ];
  };
}

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
      "chatgpt"
      "font-sketchybar-app-font"
      "keycastr"
      "obs"
      "raycast"
      "sf-symbols"
      "joplin"
      "shottr"
      "podman-desktop"

      "google-chrome"
      "zen-browser"

      "ghostty"
    ];
  };
}

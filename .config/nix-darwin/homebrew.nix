{
  homebrew = {
    enable = true; # Homebrew needs to be installed on its own!
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    brews = [
      "sketchybar"
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
      "google-chrome"
      "zen-browser"
      "joplin"
      "shottr"
      "podman-desktop"
    ];
  };
}

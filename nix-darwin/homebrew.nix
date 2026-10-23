{ config, ... }: {
  # Homebrew binaries (remindctl, imsg, gh...) must be on the system PATH so
  # non-interactive shells (launchd-spawned Hermes sessions, scripts) find them.
  environment.systemPath = [ config.homebrew.brewPrefix ];

  homebrew = {
    enable = true; # Homebrew needs to be installed on its own!
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    taps = [
      "steipete/tap"
    ];
    brews = [
      "imagemagick"
      "gh"
      "openssl@3" # hindsight-embed's postgres (libpq) links against homebrew's libssl.3.dylib
      "steipete/tap/imsg"
      "steipete/tap/remindctl"
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

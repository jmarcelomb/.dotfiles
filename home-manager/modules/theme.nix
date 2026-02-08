{ pkgs, ... }:

{
  # GTK theme configuration - Catppuccin Frappe
  gtk = {
    enable = true;

    # Catppuccin Frappe theme
    theme = {
      name = "catppuccin-frappe-blue-standard+rimless";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "frappe";
      };
    };

    # Icon theme
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # Cursor theme
    cursorTheme = {
      name = "catppuccin-frappe-dark-cursors";
      package = pkgs.catppuccin-cursors.frappeDark;
      size = 24;
    };

    # Force dark mode for GTK3/4 apps
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # Set dark color scheme via dconf for Firefox and other apps
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Environment variables to enforce dark mode
  home.sessionVariables = {
    GTK_THEME = "catppuccin-frappe-blue-standard+rimless:dark";
  };
}

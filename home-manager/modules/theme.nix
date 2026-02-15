{ pkgs, ... }:

{
  # GTK theme configuration - Catppuccin (supports both light and dark)
  gtk = {
    enable = true;

    # Default to Catppuccin Frappe (dark theme)
    theme = {
      name = "catppuccin-frappe-blue-standard+rimless";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "frappe";
      };
    };

    # Icon theme (dark by default)
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # Cursor theme (dark by default)
    cursorTheme = {
      name = "catppuccin-frappe-dark-cursors";
      package = pkgs.catppuccin-cursors.frappeDark;
      size = 24;
    };

    # Don't force dark mode - let dconf/toggle script control it
    # gtk3.extraConfig.gtk-application-prefer-dark-theme is managed by toggle script
    # gtk4.extraConfig.gtk-application-prefer-dark-theme is managed by toggle script
  };

  # Install additional themes for toggling
  home.packages = with pkgs; [
    # Light theme for toggle support
    (catppuccin-gtk.override {
      accents = [ "blue" ];
      size = "standard";
      tweaks = [ "rimless" ];
      variant = "latte";
    })
    
    # Light cursor
    catppuccin-cursors.latteDark
  ];

  # Set default color scheme via dconf (dark mode by default)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "catppuccin-frappe-blue-standard+rimless";
      icon-theme = "Papirus-Dark";
      cursor-theme = "catppuccin-frappe-dark-cursors";
    };
  };

  # Don't set GTK_THEME environment variable - it overrides dconf settings
  # The toggle script will manage themes via dconf instead
}

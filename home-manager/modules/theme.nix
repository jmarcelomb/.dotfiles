{ pkgs, ... }:

{
  # GTK theme configuration - Catppuccin Frappe
  gtk = {
    enable = true;
    
    # Catppuccin Frappe theme
    theme = {
      name = "Catppuccin-Frappe-Standard-Blue-Dark";
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
}

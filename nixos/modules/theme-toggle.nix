{ pkgs, user, ... }:

{
  # Theme toggle script for runtime switching between light and dark modes

  environment.systemPackages = with pkgs; [
    # Required for theme switching
    dconf
    gsettings-desktop-schemas
  ];

  home-manager.users.${user} = { pkgs, ... }: {
    # Install both light and dark Catppuccin themes
    home.packages = with pkgs; [
      # Dark themes (already have frappe)
      (catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "frappe";
      })

      # Light theme
      (catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "latte";
      })

      # Cursors for both variants
      catppuccin-cursors.frappeDark
      catppuccin-cursors.latteDark
    ];

    # Theme toggle script
    home.file.".local/bin/toggle-theme".source = pkgs.writeShellScript "toggle-theme" ''
      #!/usr/bin/env bash
      # Toggle between light and dark themes system-wide

      # Get current color scheme
      CURRENT=$(${pkgs.dconf}/bin/dconf read /org/gnome/desktop/interface/color-scheme)

      if [[ "$CURRENT" == "'prefer-dark'" ]]; then
        # Switch to light mode (Catppuccin Latte)
        echo "Switching to light theme..."

        # GTK theme
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'catppuccin-latte-blue-standard+rimless'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"

        # Icon theme (use light variant)
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Light'"

        # Cursor theme
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'catppuccin-latte-dark-cursors'"

        # GTK settings
        ${pkgs.gnused}/bin/sed -i '/^gtk-application-prefer-dark-theme=/c\gtk-application-prefer-dark-theme=0' ~/.config/gtk-3.0/settings.ini 2>/dev/null || true
        ${pkgs.gnused}/bin/sed -i '/^gtk-theme-name=/c\gtk-theme-name=catppuccin-latte-blue-standard+rimless' ~/.config/gtk-3.0/settings.ini 2>/dev/null || true

        # Update GTK4 settings
        ${pkgs.gnused}/bin/sed -i '/^gtk-application-prefer-dark-theme=/c\gtk-application-prefer-dark-theme=0' ~/.config/gtk-4.0/settings.ini 2>/dev/null || true
        ${pkgs.gnused}/bin/sed -i '/^gtk-theme-name=/c\gtk-theme-name=catppuccin-latte-blue-standard+rimless' ~/.config/gtk-4.0/settings.ini 2>/dev/null || true

        # Ghostty terminal theme (light mode: 0.75 opacity)
        if [ -f ~/.config/ghostty/config ]; then
          ${pkgs.gnused}/bin/sed -i '/^theme = /c\theme = Catppuccin Latte' ~/.config/ghostty/config
          ${pkgs.gnused}/bin/sed -i '/^background-opacity = /c\background-opacity = 0.75' ~/.config/ghostty/config
        fi

        # tmux theme (Catppuccin Latte)
        if [ -f ~/.config/tmux/tmux.conf ]; then
          ${pkgs.gnused}/bin/sed -i '/^set -g @catppuccin_flavor/c\set -g @catppuccin_flavor "latte"' ~/.config/tmux/tmux.conf
        fi

        # Neovim theme (Catppuccin Latte)
        # Create a theme flag file that Neovim will check
        echo "light" > ~/.config/nvim/.theme

        echo "✓ Switched to light theme (Catppuccin Latte)"

      else
        # Switch to dark mode (Kanagawa/Frappe)
        echo "Switching to dark theme..."

        # GTK theme
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'catppuccin-frappe-blue-standard+rimless'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

        # Icon theme (use dark variant)
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"

        # Cursor theme
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'catppuccin-frappe-dark-cursors'"

        # GTK settings
        ${pkgs.gnused}/bin/sed -i '/^gtk-application-prefer-dark-theme=/c\gtk-application-prefer-dark-theme=1' ~/.config/gtk-3.0/settings.ini 2>/dev/null || true
        ${pkgs.gnused}/bin/sed -i '/^gtk-theme-name=/c\gtk-theme-name=catppuccin-frappe-blue-standard+rimless' ~/.config/gtk-3.0/settings.ini 2>/dev/null || true

        # Update GTK4 settings
        ${pkgs.gnused}/bin/sed -i '/^gtk-application-prefer-dark-theme=/c\gtk-application-prefer-dark-theme=1' ~/.config/gtk-4.0/settings.ini 2>/dev/null || true
        ${pkgs.gnused}/bin/sed -i '/^gtk-theme-name=/c\gtk-theme-name=catppuccin-frappe-blue-standard+rimless' ~/.config/gtk-4.0/settings.ini 2>/dev/null || true

        # Ghostty terminal theme (dark mode: 0.93 opacity)
        if [ -f ~/.config/ghostty/config ]; then
          ${pkgs.gnused}/bin/sed -i '/^theme = /c\theme = Catppuccin Frappe' ~/.config/ghostty/config
          ${pkgs.gnused}/bin/sed -i '/^background-opacity = /c\background-opacity = 0.93' ~/.config/ghostty/config
        fi

        # tmux theme (Catppuccin Frappe)
        if [ -f ~/.config/tmux/tmux.conf ]; then
          ${pkgs.gnused}/bin/sed -i '/^set -g @catppuccin_flavor/c\set -g @catppuccin_flavor "frappe"' ~/.config/tmux/tmux.conf
        fi

        # Neovim theme (Kanagawa for dark)
        # Create a theme flag file that Neovim will check
        echo "dark" > ~/.config/nvim/.theme

        echo "✓ Switched to dark theme (Kanagawa)"
      fi

      # Restart waybar to apply GTK theme changes
      if ${pkgs.procps}/bin/pgrep waybar > /dev/null; then
        ${pkgs.procps}/bin/pkill waybar
        ${pkgs.waybar}/bin/waybar &
        disown
      fi

      # Restart Nautilus to apply theme changes (if running)
      if ${pkgs.procps}/bin/pgrep nautilus > /dev/null; then
        ${pkgs.procps}/bin/pkill nautilus
        # Nautilus will auto-restart when needed
      fi

      # Send notification
      if command -v notify-send > /dev/null; then
        if [[ "$CURRENT" == "'prefer-dark'" ]]; then
          ${pkgs.libnotify}/bin/notify-send "Theme" "Switched to light mode" -i weather-clear
        else
          ${pkgs.libnotify}/bin/notify-send "Theme" "Switched to dark mode" -i weather-clear-night
        fi
      fi
    '';

    # Make the script executable via a simple approach
    home.file.".local/bin/toggle-theme".executable = true;
  };
}

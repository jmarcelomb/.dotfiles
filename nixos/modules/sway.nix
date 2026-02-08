{ pkgs, lib, config, user, ... }:

{
  # Enable greetd display manager with login prompt
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Enable Wayland and Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      # Core utilities
      swaylock
      swayidle
      swaybg

      # Wayland-native tools
      wl-clipboard
      wlr-randr

      # Application launcher
      vicinae

      # Notification center
      swaynotificationcenter

      # Status bar
      waybar

      # Screenshot/screencast
      grim
      slurp
      swappy

      # Terminal
      ghostty

      # File manager (GNOME Files/Nautilus)
      nautilus

      # Password manager
      bitwarden-desktop

      # GNOME components for consistent experience
      gnome-calculator
      gnome-system-monitor
      gnome-settings-daemon
    ];
  };

  # Enable XDG portal for screen sharing and other features
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Enable polkit for authentication
  security.polkit.enable = true;

  # Enable gvfs for Nautilus
  services.gvfs.enable = true;

  # Home-manager configuration for Sway
  home-manager.users.${user} = { pkgs, ... }: {
    imports = [
      ./waybar.nix
    ];

    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod1"; # Alt key (Mod1 = Alt, Mod4 = Super/Windows)
        terminal = "${pkgs.ghostty}/bin/ghostty";
        menu = "${pkgs.vicinae}/bin/vicinae toggle";

        # Disable default Sway bar (using Waybar instead)
        bars = [];

        # Gaps configuration (matching Aerospace: no gaps)
        gaps = {
          inner = 0;
          outer = 0;
          smartBorders = "off";
          smartGaps = false;
        };

        # Window borders
        window = {
          border = 2;
          titlebar = false;
        };

        # Focus settings
        focus = {
          followMouse = "yes";
          mouseWarping = true;
        };

        # Keybindings matching Aerospace
        keybindings = lib.mkOptionDefault {
          # Disable default arrow key bindings (let them pass through to tmux)
          "${modifier}+Left" = null;
          "${modifier}+Right" = null;
          "${modifier}+Up" = null;
          "${modifier}+Down" = null;
          "${modifier}+Shift+Left" = null;
          "${modifier}+Shift+Right" = null;
          "${modifier}+Shift+Up" = null;
          "${modifier}+Shift+Down" = null;

          # Focus navigation (Alt+h/l)
          "${modifier}+h" = "focus left";
          "${modifier}+l" = "focus right";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";

          # Move windows (Alt+Shift+h/l)
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";

          # Toggle floating (Alt+Shift+Space)
          "${modifier}+Shift+space" = "floating toggle";

          # Workspace back and forth (Alt+Tab)
          "${modifier}+Tab" = "workspace back_and_forth";

          # Move workspace to next monitor (Alt+Shift+Tab)
          "${modifier}+Shift+Tab" = "move workspace to output right";

          # Workspace switching (Alt+1-9,0,b,s,t)
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";
          "${modifier}+b" = "workspace B";
          "${modifier}+s" = "workspace S";
          "${modifier}+t" = "workspace T";

          # Move to workspace (Alt+Shift+1-9,0,b,s,t)
          "${modifier}+Shift+1" = "move container to workspace number 1; workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2; workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3; workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4; workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5; workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6; workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7; workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8; workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9; workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10; workspace number 10";
          "${modifier}+Shift+b" = "move container to workspace B; workspace B";
          "${modifier}+Shift+t" = "move container to workspace T; workspace T";

          # Layout switching (Alt+/)
          "${modifier}+slash" = "layout toggle split";

          # Accordion-like (tabbed layout) (Alt+,)
          "${modifier}+comma" = "layout tabbed";

          # Resize mode (Alt+r)
          "${modifier}+r" = "mode resize";

          # Service mode (Alt+Shift+;)
          "${modifier}+Shift+semicolon" = "mode service";

          # Close window (Alt+Shift+q)
          "${modifier}+Shift+q" = "kill";

          # Reload configuration
          "${modifier}+Shift+c" = "reload";

          # File manager
          "${modifier}+e" = "exec ${pkgs.nautilus}/bin/nautilus";

          # Application launcher (Alt+Space)
          "${modifier}+space" = "exec ${pkgs.vicinae}/bin/vicinae toggle";

          # Notification center (Alt+N)
          "${modifier}+n" = "exec ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";

          # Clipboard history (Alt+V)
          "${modifier}+v" = "exec ${pkgs.vicinae}/bin/vicinae 'vicinae://extensions/vicinae/clipboard/history'";

          # Screenshots
          # Print: Full screen -> swappy
          "Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.swappy}/bin/swappy -f -";
          # Alt+Shift+S: Select area -> swappy
          "${modifier}+Shift+s" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.swappy}/bin/swappy -f -";

          # Volume control (capped at 200%)
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 2.0";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        # Resize mode
        modes = {
          resize = {
            # Vim keys and arrows - universal resize that works from any position
            # Left/H: make window narrower (move right edge left)
            h = "resize shrink width 50 px";
            Left = "resize shrink width 50 px";
            # Right/L: make window wider (move right edge right)
            l = "resize grow width 50 px";
            Right = "resize grow width 50 px";
            # Up/K: make window shorter (move bottom edge up)
            k = "resize shrink height 50 px";
            Up = "resize shrink height 50 px";
            # Down/J: make window taller (move bottom edge down)
            j = "resize grow height 50 px";
            Down = "resize grow height 50 px";
            # Exit resize mode
            Return = "mode default";
            Escape = "mode default";
          };

          # Service mode (matching Aerospace service mode)
          service = {
            Escape = "reload; mode default";
            r = "layout default; mode default"; # Reset layout
            f = "floating toggle; mode default"; # Toggle floating
            "${modifier}+Shift+h" = "split h; mode default";
            "${modifier}+Shift+j" = "split v; mode default";
            "${modifier}+Shift+k" = "split v; mode default";
            "${modifier}+Shift+l" = "split h; mode default";
          };
        };

        # Window rules (matching Aerospace on-window-detected)
        window.commands = [
          # Vicinae (application launcher) - floating centered
          { criteria = { app_id = "^vicinae$"; }; command = "floating enable, border pixel 2, resize set 800 600"; }

          # Browsers to workspace 1
          { criteria = { app_id = "^firefox$"; }; command = "move container to workspace number 1"; }
          { criteria = { app_id = "^zen-browser$"; }; command = "move container to workspace number 1"; }
          { criteria = { app_id = "^chromium-browser$"; }; command = "move container to workspace number 1"; }
          { criteria = { app_id = "^google-chrome$"; }; command = "move container to workspace number 1"; }
          { criteria = { class = "^Google-chrome$"; }; command = "move container to workspace number 1"; }

          # Terminals to workspace 2
          { criteria = { app_id = "^com\\.mitchellh\\.ghostty$"; }; command = "move container to workspace number 2"; }
          { criteria = { app_id = "^kitty$"; }; command = "move container to workspace number 2"; }
          { criteria = { app_id = "^Alacritty$"; }; command = "move container to workspace number 2"; }

          # VM to workspace 3
          { criteria = { class = "^vmware$"; }; command = "move container to workspace number 3"; }

          # VSCode to workspace 5
          { criteria = { class = "^code$"; }; command = "move container to workspace number 5"; }
          { criteria = { class = "^VSCodium$"; }; command = "move container to workspace number 5"; }

          # OBS to workspace 8
          { criteria = { class = "^obs$"; }; command = "move container to workspace number 8"; }

          # Notes/productivity to workspace 9
          { criteria = { class = "^joplin$"; }; command = "move container to workspace number 9"; }
          { criteria = { class = "^OneNote$"; }; command = "move container to workspace number 9"; }

          # Communication to workspace 10
          { criteria = { class = "^discord$"; }; command = "move container to workspace number 10"; }
          { criteria = { class = "^Messenger$"; }; command = "move container to workspace number 10"; }
          { criteria = { class = "^whatsapp$"; }; command = "move container to workspace number 10"; }

          # Bambu, Bitwarden to workspace B
          { criteria = { class = "^bambu-studio$"; }; command = "move container to workspace B"; }
          { criteria = { class = "^Bitwarden$"; }; command = "move container to workspace B"; }

          # Spotify to workspace S
          { criteria = { class = "^Spotify$"; }; command = "move container to workspace S"; }

          # Teams/Zoom to workspace T
          { criteria = { class = "^teams$"; }; command = "move container to workspace T"; }
          { criteria = { class = "^zoom$"; }; command = "move container to workspace T"; }
        ];

        # Output configuration (monitors)
        # You can customize this based on your monitor setup
        output = {
          "*" = {
            bg = "#1e1e2e solid_color";
          };
        };

        # Input configuration
        input = {
          # Keyboard settings (all keyboards)
          "type:keyboard" = {
            xkb_layout = "us";
            repeat_delay = "180";  # Delay before repeat starts (milliseconds)
            repeat_rate = "40";    # Characters per second when repeating
          };

          # Touchpad settings (all touchpads)
          "type:touchpad" = {
            natural_scroll = "enabled";  # Inverted/natural scrolling
            tap = "enabled";             # Tap to click
            dwt = "enabled";             # Disable while typing
            middle_emulation = "enabled"; # Middle click emulation
          };

          # Fallback for devices that don't match type
          "*" = {
            xkb_layout = "us";
          };
        };

        # Startup commands
        startup = [
          # Import environment variables to systemd for proper app launching
          { command = "systemctl --user import-environment PATH DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"; }
          { command = "hash dbus-update-activation-environment 2>/dev/null && dbus-update-activation-environment --systemd PATH DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"; }

          # Notification center
          { command = "${pkgs.swaynotificationcenter}/bin/swaync"; }

          # Waybar status bar
          { command = "${pkgs.waybar}/bin/waybar"; }

          # Idle management
          { command = ''
            ${pkgs.swayidle}/bin/swayidle -w \
              timeout 300 '${pkgs.swaylock}/bin/swaylock -f' \
              timeout 600 'swaymsg "output * dpms off"' \
              resume 'swaymsg "output * dpms on"' \
              before-sleep '${pkgs.swaylock}/bin/swaylock -f'
          ''; }

          # GNOME Settings Daemon for better integration
          { command = "${pkgs.gnome-settings-daemon}/libexec/gsd-xsettings"; }

          # Switch to workspace 1 on login
          { command = "swaymsg workspace number 1"; }
        ];
      };
    };

    # SwayNotificationCenter - using defaults, can be customized later
    # Config files will be at ~/.config/swaync/ if you want to customize

    # Vicinae application launcher service
    systemd.user.services.vicinae = {
      Unit = {
        Description = "Vicinae application launcher server";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.vicinae}/bin/vicinae server";
        Restart = "on-failure";
        RestartSec = 3;
        Environment = [
          "USE_LAYER_SHELL=1"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

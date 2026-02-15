{ pkgs, lib, config, user, self, ... }:

let
  wallpaper = "${self}/assets/wallpapers/poland.png";
  lockWallpaper = "${self}/assets/wallpapers/poland-lock.png";
in
{
  # Enable greetd display manager with login prompt
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --user-menu --remember --cmd sway";
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
      wdisplays

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

      # Wayland-native dock for Sway
      nwg-dock
      # Screen brightness utility
      brightnessctl
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

        # Colors (Catppuccin theme-aware)
        # These colors work well for both Catppuccin Latte (light) and Frappe (dark)
        colors = {
          focused = {
            border = "#8caaee";       # Catppuccin blue (same in both themes)
            background = "#8caaee";
            text = "#c6d0f5";
            indicator = "#81c8be";    # Catppuccin teal
            childBorder = "#8caaee";
          };
          focusedInactive = {
            border = "#babbf1";       # Catppuccin lavender (lighter for light theme)
            background = "#303446";
            text = "#c6d0f5";
            indicator = "#babbf1";
            childBorder = "#babbf1";
          };
          unfocused = {
            border = "#e6e9ef";       # Catppuccin Latte surface0 (very light gray)
            background = "#eff1f5";   # Catppuccin Latte base
            text = "#8c8fa1";         # Catppuccin Latte overlay0
            indicator = "#e6e9ef";
            childBorder = "#e6e9ef";
          };
          urgent = {
            border = "#e78284";       # Catppuccin red (alert color)
            background = "#e78284";
            text = "#c6d0f5";
            indicator = "#e78284";
            childBorder = "#e78284";
          };
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

          # Move workspace to other monitor (Alt+Shift+Tab)
          # Moves workspace up in vertical stack, wraps around to bottom
          "${modifier}+Shift+Tab" = "move workspace to output up";

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

          # Close window (Alt+Shift+q or Alt+W)
          "${modifier}+Shift+q" = "kill";
          "${modifier}+w" = "kill";

          # Minimize window (Alt+M) - moves to scratchpad
          "${modifier}+m" = "move scratchpad";

          # Show/restore minimized windows (Alt+Shift+M)
          "${modifier}+Shift+m" = "scratchpad show";

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

          # Window switcher / Dock (Alt+D) - shows all open windows including minimized
          "${modifier}+d" = "exec ${pkgs.vicinae}/bin/vicinae 'vicinae://extensions/vicinae/wm/switch-windows'";

          # Toggle nwg-dock visibility (Alt+Shift+D)
          "${modifier}+Shift+d" = "exec pgrep -x nwg-dock && pkill nwg-dock || nwg-dock -nolauncher -nows -i 48 -mb 4 &";

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

          # Screen brightness controls
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

          # Lock screen (Super+L)
          "Mod4+l" = "exec ${pkgs.swaylock}/bin/swaylock -f -i ${lockWallpaper}";

          # Display/Monitor settings (Alt+Shift+O for Output)
          "${modifier}+Shift+o" = "exec ${pkgs.wdisplays}/bin/wdisplays";

          # Theme toggle (Alt+Shift+P for Palette/Preferences)
          "${modifier}+Shift+p" = "exec ~/.local/bin/toggle-theme";
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

          # Nwg-dock - floating, no border, sticky (shows on all workspaces)
          { criteria = { app_id = "^nwg-dock"; }; command = "floating enable, border none, sticky enable"; }

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
          { criteria = { app_id = "^Bitwarden$"; }; command = "move container to workspace B"; }

          # Spotify to workspace S
          { criteria = { class = "^Spotify$"; }; command = "move container to workspace S"; }

          # Teams/Zoom to workspace T
          { criteria = { class = "^teams$"; }; command = "move container to workspace T"; }
          { criteria = { class = "^zoom$"; }; command = "move container to workspace T"; }
        ];

        # Output configuration (monitors)
        # IMPORTANT: Monitor names (eDP-1, DP-2, etc.) are hardware-specific and may differ on your system
        # To find your monitor names, run one of these commands:
        #   swaymsg -t get_outputs            # Shows detailed JSON output
        #   wlr-randr                         # Shows formatted list of outputs
        #   wdisplays                         # GUI tool (press Alt+Shift+O)
        # Common monitor name patterns:
        #   eDP-1, eDP-2          -> Built-in laptop screens
        #   HDMI-A-1, HDMI-A-2    -> HDMI ports
        #   DP-1, DP-2, DP-3      -> DisplayPort connections
        #   DVI-D-1               -> DVI connections
        output = {
          # Default wallpaper for all monitors
          "*" = {
            bg = "${wallpaper} fill";
          };
          
          # Secondary monitor (external display) - positioned at top
          "DP-2" = {
            position = "0,0";  # Top position (external monitor on top)
            # Uncomment to set specific resolution/refresh rate:
            # mode = "1920x1080@60Hz";
            # scale = "1.0";
          };
          
          # Primary monitor (laptop screen) - positioned below external monitor
          # Change position to "1920,0" for side by side (laptop on right)
          # Change to "-1920,0" for side by side (laptop on left)
          "eDP-1" = {
            position = "0,1080";  # Below DP-2 (vertical stack)
            # Uncomment to set specific resolution/refresh rate:
            # mode = "1920x1080@60Hz";
            # scale = "1.0";
          };
        };

        # Workspace to monitor assignments
        # Removed fixed assignments for full flexibility - workspaces can be moved freely between monitors
        # Use Alt+Shift+Tab to move the current workspace to another monitor
        # Workspaces will appear on whichever monitor is currently focused when you first switch to them

        # Input configuration
        input = {
          # Keyboard settings (all keyboards)
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_options = "compose:ralt";  # Right Alt as Compose key for accented characters
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
            xkb_options = "compose:ralt";
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
              timeout 60 '${pkgs.swaylock}/bin/swaylock -f -i ${lockWallpaper}' \
              timeout 120 'swaymsg "output * dpms off"' \
              resume 'swaymsg "output * dpms on"' \
              before-sleep '${pkgs.swaylock}/bin/swaylock -f -i ${lockWallpaper}'
          ''; }

          # GNOME Settings Daemon for better integration
          { command = "${pkgs.gnome-settings-daemon}/libexec/gsd-xsettings"; }

          # Switch to workspace 1 on login (workspace 1 is on DP-2, the main external display)
          { command = "swaymsg workspace number 1"; }
          
          # Focus the external monitor (DP-2) at startup
          { command = "swaymsg focus output DP-2"; }
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

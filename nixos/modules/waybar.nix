{ pkgs, nerdFontName ? "monospace", ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "backlight" "network" "cpu" "memory" "battery" "clock" ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          format = "{name}";
        };

        "sway/window" = {
          format = "{title}";
          icon = true;
          icon-size = 16;
          max-length = 60;
        };

        "sway/mode" = {
          format = "{}";
        };

        clock = {
          format = "DATETIME <b>{:%H:%M %d/%m}</b>";
          tooltip-format = "{:%Y-%m-%d | %H:%M:%S}";
        };

        cpu = {
          format = "CPU <b>{usage}%</b>";
        };

        memory = {
          format = "MEM <b>{percentage}%</b>";
        };

        battery = {
          format = "BAT <b>{capacity}%</b>";
        };

        pulseaudio = {
          format = "VOL <b>{volume}%</b>";
          format-muted = "<b>MUTE</b>";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 2.0";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          scroll-step = 5;
          max-volume = 200;
        };

        backlight = {
          device = "intel_backlight";
          format = "BRI <b>{percent}%</b>";
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        network = {
          format-wifi = "NET <b>{essid}</b>";
          format-ethernet = "NET <b>Wired</b>";
          format-disconnected = "NET <b>Disconnected</b>";
        };
      };
    };

    style = ''
      * {
        font-family: "${nerdFontName}", monospace;
        font-size: 13px;
      }

      window#waybar {
        background-color: @theme_bg_color;
        color: @theme_fg_color;
      }

      #workspaces button {
        padding: 0 8px;
        color: @theme_fg_color;
        background-color: transparent;
        border: none;
      }

      #workspaces button.focused {
        background-color: @theme_selected_bg_color;
        color: #ffffff;
      }

      #workspaces button.urgent {
        background-color: @error_color;
      }

      #mode {
        background-color: @warning_color;
        color: @theme_bg_color;
        padding: 0 10px;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #backlight {
        padding: 0 10px;
      }
    '';
};
}

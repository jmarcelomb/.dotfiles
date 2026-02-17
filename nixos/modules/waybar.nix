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
        modules-right = [ "battery" "custom/power-mode" "cpu" "memory" "network" "backlight" "pulseaudio" "clock" ];

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
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} <b>{capacity}%</b> {power:.1f}W";
          format-charging = " <b>{capacity}%</b> {power:.1f}W";
          format-plugged = " <b>{capacity}%</b>";
          format-icons = ["" "" "" "" ""];
          tooltip-format = "Battery: {capacity}% ({timeTo})\nPower: {power:0.2f}W\nHealth: {health}%\nCycles: {cycles}\n\nClick to toggle power mode";
          on-click = "tlp-toggle";
        };

        "custom/power-mode" = {
          exec = "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor | sed 's/performance/PERF/; s/powersave/SAVE/'";
          interval = 2;
          format = "MODE <b>{}</b>";
          tooltip-format = "Current CPU governor\nClick battery to toggle";
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
      #backlight,
      #custom-power-mode {
        padding: 0 10px;
      }

      #battery.charging {
        color: #26A65B;
      }

      #battery.warning:not(.charging) {
        color: #ffcc00;
      }

      #battery.critical:not(.charging) {
        color: #ff0000;
        animation: blink 1s linear infinite;
      }

      @keyframes blink {
        to {
          opacity: 0.5;
        }
      }
    '';
};
}

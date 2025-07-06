{
  services.aerospace = {
    enable = true;
    settings = {
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 0;
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "/run/current-system/sw/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$(/run/current-system/sw/bin/aerospace list-workspaces --focused)"
      ];
      on-focus-changed = [
        "exec-and-forget /run/current-system/sw/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$(/run/current-system/sw/bin/aerospace list-workspaces --focused)"
      ];

      gaps = {
        inner = {
          horizontal = 0;
          vertical = 0;
        };
        outer = {
          left = 0;
          bottom = 0;
          top = 30;
          right = 0;
        };
      };

      mode = {
        main = {
          binding = {
            alt-h = "focus left";
            alt-l = "focus right";

            alt-shift-h = "move left";
            alt-shift-l = "move right";

            alt-shift-space = "layout floating tiling";

            alt-tab = "workspace-back-and-forth";
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

            alt-1 = "workspace 1";
            alt-2 = "workspace 2";
            alt-3 = "workspace 3";
            alt-4 = "workspace 4";
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";
            alt-7 = "workspace 7";
            alt-8 = "workspace 8";
            alt-9 = "workspace 9";
            alt-0 = "workspace 10";
            alt-b = "workspace B";
            alt-s = "workspace S";
            alt-t = "workspace T";

            alt-shift-1 = [
              "move-node-to-workspace 1"
              "workspace 1"
            ];
            alt-shift-2 = [
              "move-node-to-workspace 2"
              "workspace 2"
            ];
            alt-shift-3 = [
              "move-node-to-workspace 3"
              "workspace 3"
            ];
            alt-shift-4 = [
              "move-node-to-workspace 4"
              "workspace 4"
            ];
            alt-shift-5 = [
              "move-node-to-workspace 5"
              "workspace 5"
            ];
            alt-shift-6 = [
              "move-node-to-workspace 6"
              "workspace 6"
            ];
            alt-shift-7 = [
              "move-node-to-workspace 7"
              "workspace 7"
            ];
            alt-shift-8 = [
              "move-node-to-workspace 8"
              "workspace 8"
            ];
            alt-shift-9 = [
              "move-node-to-workspace 9"
              "workspace 9"
            ];
            alt-shift-0 = [
              "move-node-to-workspace 10"
              "workspace 10"
            ];
            alt-shift-b = [
              "move-node-to-workspace B"
              "workspace B"
            ];
            alt-shift-s = [
              "move-node-to-workspace S"
              "workspace S"
            ];
            alt-shift-t = [
              "move-node-to-workspace T"
              "workspace T"
            ];


            alt-shift-semicolon = "mode service";

            alt-slash = "layout tiles horizontal vertical";
            alt-comma = "layout accordion horizontal vertical";

            alt-r = "mode resize";
          };
        };

        resize = {
          binding = {
            h = "resize width -50";
            j = "resize height +50";
            k = "resize height -50";
            l = "resize width +50";
            left = "resize width -50";
            down = "resize height +50";
            up = "resize height -50";
            right = "resize width +50";
            enter = "mode main";
            esc = "mode main";
          };
        };

        service = {
          binding = {
            esc = ["reload-config" "mode main"];
            r = ["flatten-workspace-tree" "mode main"]; # reset layout
            f = ["layout floating tiling" "mode main"]; # Toggle between floating and tiling layout
            backspace = ["close-all-windows-but-current" "mode main"];

            # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
            #s = ["layout sticky tiling" "mode main"];

            alt-shift-h = ["join-with left" "mode main"];
            alt-shift-j = ["join-with down" "mode main"];
            alt-shift-k = ["join-with up" "mode main"];
            alt-shift-l = ["join-with right" "mode main"];
            alt-shift-left = ["join-with left" "mode main"];
            alt-shift-down = ["join-with down" "mode main"];
            alt-shift-up = ["join-with up" "mode main"];
            alt-shift-right = ["join-with right" "mode main"];
          };
        };
      };

      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
        "6" = "secondary";
        "7" = "secondary";
        "8" = "secondary";
        "9" = "secondary";
        "10" = "secondary";
        "B" = "secondary";
        "S" = "secondary";
        "T" = "secondary";
      };

      on-window-detected = [
        {
          "if".app-id = "app.zen-browser.zen";
          run = [ "move-node-to-workspace 1" ];
        }
        {
          "if".app-id = "com.apple.Safari";
          run = [ "move-node-to-workspace 1" ];
        }
        {
          "if".app-id = "com.kagi.kagimacOS";
          run = [ "move-node-to-workspace 1" ];
        }
        {
          "if".app-id = "net.cozic.joplin-desktop";
          run = [ "move-node-to-workspace 9" ];
        }
        {
          "if".app-id = "com.apple.Terminal";
          run = [ "move-node-to-workspace 2" ];
        }
        {
          "if".app-id = "com.raphaelamorim.rio";
          run = [ "move-node-to-workspace 2" ];
        }
        {
          "if".app-id = "net.kovidgoyal.kitty";
          run = [ "move-node-to-workspace 2" ];
        }
        {
          "if".app-id = "com.vmware.fusion";
          run = [ "move-node-to-workspace 3" ];
        }
        {
          "if".app-id = "com.microsoft.VSCode";
          run = [ "move-node-to-workspace 5" ];
        }
        {
          "if".app-id = "com.obsproject.obs-studio";
          run = [ "move-node-to-workspace 8" ];
        }
        {
          "if".app-id = "com.hnc.Discord";
          run = [ "move-node-to-workspace 10" ];
        }
        {
          "if".app-id = "com.facebook.archon.developerID";
          run = [ "move-node-to-workspace 10" ];
        }
        {
          "if".app-id = "net.whatsapp.WhatsApp";
          run = [ "move-node-to-workspace 10" ];
        }
        {
          "if".app-id = "com.apple.MobileSMS";
          run = [ "move-node-to-workspace 10" ];
        }
        {
          "if".app-id = "com.openai.chat";
          run = [ "move-node-to-workspace 9" ];
        }
        {
          "if".app-id = "com.bambulab.bambu-studio";
          run = [ "move-node-to-workspace B" ];
        }
        {
          "if".app-id = "com.bitwarden.desktop";
          run = [ "move-node-to-workspace B" ];
        }        {
          "if".app-id = "com.spotify.client";
          run = [ "move-node-to-workspace S" ];
        }
        {
          "if".app-id = "com.microsoft.teams2";
          run = [ "move-node-to-workspace T" ];
        }
        {
          "if".app-id = "us.zoom.xos";
          run = [ "move-node-to-workspace T" ];
        }
        {
          "if".app-id = "com.microsoft.onenote.mac";
          run = [ "move-node-to-workspace 9" ];
        }
      ];
    };
  };
}

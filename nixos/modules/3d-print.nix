{ pkgs, lib, config, user, ... }:

{
  # 3D Printing module
  # Provides slicing software and 3D printing utilities

  # System-level packages
  environment.systemPackages = with pkgs; [
    # 3D Slicing software
    # Note: Bambu Studio requires AppImage due to webkit2gtk-4.0 dependency
    # Run with: nix-shell -p webkitgtk_4_1 --run "appimage-run ~/Downloads/Bambu_Studio*.AppImage"

    # Alternative slicers that work natively on NixOS
    prusa-slicer  # Popular slicer, works with many printers
    # orca-slicer # Fork of Bambu Studio (uncomment if available in your nixpkgs)
  ];

  # Home-manager configuration for 3D printing applications
  home-manager.users.${user} = { pkgs, ... }: {
    # STL file associations
    xdg.mimeApps = {
      associations.added = {
        "model/stl" = "PrusaSlicer.desktop";
        "application/sla" = "PrusaSlicer.desktop";
      };
      defaultApplications = {
        "model/stl" = "PrusaSlicer.desktop";
        "application/sla" = "PrusaSlicer.desktop";
      };
    };

    # Configure Sway window rules for 3D printing applications if Sway is enabled
    wayland.windowManager.sway.config.window.commands = lib.mkIf (config.programs.sway.enable or false) [
      # PrusaSlicer to workspace 5 (3D printing workspace)
      { criteria = { app_id = "^prusa-slicer$"; }; command = "move container to workspace number 5"; }
      { criteria = { class = "^PrusaSlicer$"; }; command = "move container to workspace number 5"; }

      # Bambu Studio to workspace 5 (3D printing workspace)
      { criteria = { title = "^Bambu Studio.*"; }; command = "move container to workspace number 5"; }
    ];
  };
}

{ pkgs, lib, config, user, ... }:

{
  # CAD applications module
  # Provides FreeCAD and KiCAD for mechanical and electronics design

  # System-level packages
  environment.systemPackages = with pkgs; [
    # Mechanical CAD
    freecad

    # Electronics CAD
    kicad
  ];

  # Home-manager configuration for CAD applications
  home-manager.users.${user} = { pkgs, ... }: {
    # FreeCAD desktop entry and configuration
    # FreeCAD files are typically .FCStd
    xdg.mimeApps = {
      associations.added = {
        "application/x-freecad" = "freecad.desktop";
      };
      defaultApplications = {
        "application/x-freecad" = "freecad.desktop";
      };
    };

    # Configure Sway window rules for CAD applications if Sway is enabled
    wayland.windowManager.sway.config.window.commands = lib.mkIf (config.programs.sway.enable or false) [
      # FreeCAD to workspace 4 (CAD workspace)
      { criteria = { app_id = "^freecad$"; }; command = "move container to workspace number 4"; }
      { criteria = { class = "^FreeCAD$"; }; command = "move container to workspace number 4"; }

      # KiCAD to workspace 4 (CAD workspace)
      { criteria = { app_id = "^kicad$"; }; command = "move container to workspace number 4"; }
      { criteria = { class = "^KiCad$"; }; command = "move container to workspace number 4"; }
      { criteria = { class = "^kicad$"; }; command = "move container to workspace number 4"; }
    ];
  };
}

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
    # orca-slicer # Fork of Bambu Studio (uncomment if available in your nixpkgs)

    # 3D Model viewers and preview tools
    f3d  # Fast 3D viewer with thumbnailer support for STL previews in Nautilus
  ];

  # Home-manager configuration for 3D printing applications
  home-manager.users.${user} = { pkgs, ... }: {
    # Install f3d for the user (provides thumbnailer)
    home.packages = with pkgs; [
      f3d  # 3D model viewer with thumbnailer support
    ];

    # STL file associations
    xdg.mimeApps = {
      associations.added = {
        "model/stl" = "f3d.desktop";
      };
      defaultApplications = {
        "model/stl" = "f3d.desktop";
      };
    };

    # Configure Sway window rules for 3D printing applications if Sway is enabled
    wayland.windowManager.sway.config.window.commands = lib.mkIf (config.programs.sway.enable or false) [
      # Bambu Studio to workspace 5 (3D printing workspace)
      { criteria = { title = "^Bambu Studio.*"; }; command = "move container to workspace number 5"; }
    ];
  };
}

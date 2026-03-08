{ pkgs, lib, config, user, ... }:

with lib;

let
  cfg = config.hardware.nvidia.prime.autoOffload;

  # NVIDIA environment variables for PRIME offload
  nvidiaEnvVars = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  # Wrapper function to add NVIDIA env vars to a package
  wrapWithNvidia = pkg: pkgs.symlinkJoin {
    name = "${pkg.name}-nvidia";
    paths = [ pkg ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Wrap all executables in bin/
      for file in ${pkg}/bin/*; do
        if [ -f "$file" ] && [ -x "$file" ]; then
          local exe="$out/bin/$(basename "$file")"
          echo "Wrapping $exe with NVIDIA env vars"
          rm -f "$exe"
          makeWrapper "$file" "$exe" \
            --set __NV_PRIME_RENDER_OFFLOAD 1 \
            --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
            --set __GLX_VENDOR_LIBRARY_NAME nvidia \
            --set __VK_LAYER_NV_optimus NVIDIA_only
        fi
      done
    '';
  };

  # Wrapper function for Qt applications that need XWayland
  wrapQtWithNvidia = pkg: pkgs.symlinkJoin {
    name = "${pkg.name}-nvidia-qt";
    paths = [ pkg ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Wrap all executables in bin/
      for file in ${pkg}/bin/*; do
        if [ -f "$file" ] && [ -x "$file" ]; then
          local exe="$out/bin/$(basename "$file")"
          echo "Wrapping $exe with NVIDIA env vars + QT_QPA_PLATFORM=xcb"
          rm -f "$exe"
          makeWrapper "$file" "$exe" \
            --set __NV_PRIME_RENDER_OFFLOAD 1 \
            --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
            --set __GLX_VENDOR_LIBRARY_NAME nvidia \
            --set __VK_LAYER_NV_optimus NVIDIA_only \
            --set QT_QPA_PLATFORM xcb
        fi
      done
    '';
  };

  # Default GPU-intensive applications
  # These are wrapped automatically unless explicitly excluded
  defaultGpuApps = with pkgs; [
    # Web Browsers (GPU acceleration for rendering, video, WebGL)
    # librewolf
    # firefox
    # chromium
    # google-chrome

    # 3D CAD applications
    # freecad

    # Electronics CAD
    # kicad

    # 3D Printing slicers
    # prusa-slicer

    # Video editing & streaming
    # obs-studio
    # kdenlive
    # blender

    # Image editing
    # gimp
    # inkscape
    # krita

    # Games & game platforms
    # steam
    # lutris

    # Video players with hardware decoding
    # vlc
    # mpv
  ];

  # Get the actual apps to wrap from config or use defaults
  appsToWrap = cfg.applications;

in
{
  options.hardware.nvidia.prime.autoOffload = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable automatic NVIDIA PRIME offload for GPU-intensive applications.

        When enabled, specified applications will automatically use the NVIDIA GPU
        without needing to manually run them with nvidia-offload.

        This mimics the behavior of GNOME's "Launch using Discrete Graphics Card"
        and Pop!_OS's automatic GPU switching.
      '';
    };

    applications = mkOption {
      type = types.listOf types.package;
      default = [];
      example = literalExpression ''
        with pkgs; [
          librewolf
          firefox
          freecad
          prusa-slicer
        ]
      '';
      description = ''
        List of packages that should automatically use the NVIDIA GPU.

        These applications will be wrapped with NVIDIA environment variables,
        making GPU offload transparent to the user.

        Common GPU-intensive applications include:
        - Web browsers (for WebGL, video acceleration)
        - CAD software (FreeCAD, KiCad)
        - 3D printing slicers
        - Video editing tools
        - Games

        Note: GTK and Electron apps work directly. Qt apps are automatically
        handled with QT_QPA_PLATFORM=xcb (see qtApplications option).
      '';
    };

    qtApplications = mkOption {
      type = types.listOf types.package;
      default = [];
      example = literalExpression ''
        with pkgs; [
          freecad
          kicad
          prusa-slicer
        ]
      '';
      description = ''
        List of Qt-based packages that need NVIDIA GPU with XWayland.

        Qt applications on Wayland often need QT_QPA_PLATFORM=xcb to properly
        use NVIDIA GPU offload. This option automatically adds that variable.

        Common Qt applications:
        - FreeCAD
        - KiCad
        - PrusaSlicer
        - OBS Studio
        - Kdenlive
      '';
    };

    swayEnvironment = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Inject NVIDIA environment variables into Sway session.

        This ensures Wayland-native applications that don't use desktop entries
        (or are launched via terminal) also have access to GPU offload.
      '';
    };

    appIdPatterns = mkOption {
      type = types.listOf types.str;
      default = [
        "^librewolf$"
        "^firefox$"
        "^chromium-browser$"
        "^google-chrome$"
        "^freecad$"
        "^FreeCAD$"
        "^kicad$"
        "^prusa-slicer$"
        "^obs$"
        "^blender$"
        "^steam$"
      ];
      description = ''
        Application ID patterns for Sway window rules.

        These patterns will be matched against app_id and class names
        to ensure the applications run with GPU acceleration.
      '';
    };
  };

  config = mkIf (cfg.enable && config.hardware.nvidia.prime.offload.enable or false) {
    # Inject NVIDIA environment into Sway if enabled
    programs.sway.extraSessionCommands = mkIf cfg.swayEnvironment ''
      # NVIDIA PRIME Offload environment variables
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
    '';

    # Add wrapped applications and user-facing utilities to system packages
    environment.systemPackages =
      (map wrapWithNvidia appsToWrap) ++
      (map wrapQtWithNvidia cfg.qtApplications) ++ [
      # nvidia-offload command is already provided by NixOS NVIDIA module
      # Add a script to check which GPU is being used
      (pkgs.writeShellScriptBin "gpu-check" ''
        #!/usr/bin/env bash
        # Check which GPU is currently rendering

        echo "=== GPU Information ==="
        echo

        if command -v glxinfo &> /dev/null; then
          echo "OpenGL Renderer:"
          glxinfo | grep "OpenGL renderer" | sed 's/^/  /'
          echo
          echo "OpenGL Vendor:"
          glxinfo | grep "OpenGL vendor" | sed 's/^/  /'
          echo
        fi

        if command -v nvidia-smi &> /dev/null; then
          echo "=== NVIDIA GPU Status ==="
          nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits | \
            awk -F', ' '{printf "  GPU: %s\n  Utilization: %s%%\n  Memory: %s/%s MB\n", $1, $2, $3, $4}'
          echo
          echo "=== Running Processes on NVIDIA GPU ==="
          nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader | \
            sed 's/^/  /' || echo "  No processes running on NVIDIA GPU"
        fi

        echo
        echo "=== Environment Variables ==="
        env | grep -E "(NV_PRIME|GLX_VENDOR|VK_LAYER)" | sed 's/^/  /' || echo "  No NVIDIA environment variables set"
      '')

      # Script to toggle GPU mode (for advanced users)
      (pkgs.writeShellScriptBin "gpu-mode" ''
        #!/usr/bin/env bash
        # Toggle between Intel and NVIDIA GPU modes

        case "$1" in
          nvidia)
            echo "Setting NVIDIA GPU mode (all apps will use NVIDIA)"
            export __NV_PRIME_RENDER_OFFLOAD=1
            export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            export __VK_LAYER_NV_optimus=NVIDIA_only
            echo "Environment variables set. Launch applications from this shell to use NVIDIA."
            ;;
          intel)
            echo "Setting Intel GPU mode (integrated graphics)"
            unset __NV_PRIME_RENDER_OFFLOAD
            unset __NV_PRIME_RENDER_OFFLOAD_PROVIDER
            unset __GLX_VENDOR_LIBRARY_NAME
            unset __VK_LAYER_NV_optimus
            echo "NVIDIA environment variables cleared. Apps will use Intel GPU."
            ;;
          status)
            if [ -n "$__NV_PRIME_RENDER_OFFLOAD" ]; then
              echo "Current mode: NVIDIA GPU"
            else
              echo "Current mode: Intel GPU (integrated)"
            fi
            ;;
          *)
            echo "Usage: gpu-mode {nvidia|intel|status}"
            echo
            echo "  nvidia  - Set environment to use NVIDIA GPU"
            echo "  intel   - Set environment to use Intel GPU"
            echo "  status  - Show current GPU mode"
            echo
            echo "Note: This affects applications launched from the current shell."
            echo "System-wide configured apps will still use their configured GPU."
            exit 1
            ;;
        esac
      '')
    ];

    # Inform user about the configuration
    environment.etc."nvidia-prime-info.txt".text = ''
      NVIDIA PRIME Auto-Offload Configuration
      ========================================

      Your system is configured with automatic GPU offload for selected applications.

      Configured GTK/Electron Applications:
      ${concatMapStringsSep "\n" (pkg: "  - ${pkg.name}") appsToWrap}

      Configured Qt Applications (with XWayland):
      ${concatMapStringsSep "\n" (pkg: "  - ${pkg.name}") cfg.qtApplications}

      These applications will automatically use your NVIDIA GPU without manual intervention.
      Qt applications are configured to use XWayland (QT_QPA_PLATFORM=xcb) for proper GPU offload.

      Useful Commands:
        gpu-check         - Show current GPU status and running processes
        gpu-mode nvidia   - Enable NVIDIA for current shell session
        gpu-mode intel    - Disable NVIDIA for current shell session
        gpu-mode status   - Show current GPU mode
        nvidia-offload    - Manually run any command with NVIDIA GPU
        nvidia-smi        - Show NVIDIA GPU status and processes

      To add more applications to GPU offload, edit your configuration:
        hardware.nvidia.prime.autoOffload = {
          applications = with pkgs; [
            librewolf      # GTK/Electron apps
            firefox
          ];
          qtApplications = with pkgs; [
            freecad        # Qt apps (auto-configured for XWayland)
            kicad
            prusa-slicer
          ];
        };
    '';
  };
}

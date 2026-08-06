# Byakugan - Desktop NixOS system
{ pkgs, inputs, stateVersion, hostname, user, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    ../../nixos/hardware/bootloader.nix
    ../../nixos/hardware/nfs-client.nix  # Just enable NFS support, no mounts

    # Profiles
    ../../nixos/profiles/base.nix
    ../../nixos/profiles/desktop.nix

    # Additional modules
    ../../nixos/modules/home-manager.nix
    ../../nixos/modules/net.nix
    ../../nixos/modules/nix.nix
    ../../nixos/modules/timezone.nix
    ../../nixos/modules/boot.nix
    ../../nixos/modules/cad.nix
    ../../nixos/modules/tlp.nix
    ../../nixos/modules/nvidia-prime.nix
  ];

  # Host-specific configuration
  # (Most config comes from profiles above)

  # Enable KDE Connect for phone integration
  programs.kdeconnect.enable = true;

  # Host-specific packages (non-GPU apps)
  environment.systemPackages = with pkgs; [
    bluetui       # Bluetooth TUI manager
    sushi         # Quick Look-style file previewer (press Space in Nautilus)
    libheif       # HEIC/HEIF image format support and CLI tools
    libheif.out   # Additional HEIC/HEIF libraries and binaries
    ffmpeg        # Multimedia framework for video/audio processing

    # GStreamer plugins for video preview in Nautilus
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav  # FFmpeg-based plugins for additional format support

    # GPU-intensive apps (zen-browser, vlc, spotify) are configured below in hardware.nvidia.prime.autoOffload
  ];

  # Optional: Add NFS mounts if needed
  # fileSystems."/mnt/media" = {
  #   device = "nas.local:/media";
  #   fsType = "nfs";
  #   options = [ "nfsvers=4" "rw" "soft" "intr" ];
  # };

  # NVIDIA proprietary driver with PRIME support
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:3:0:0";
    };
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false; # Use proprietary driver
  };

  # Enable OpenGL and Vulkan support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Automatic GPU offload for GPU-intensive applications
  hardware.nvidia.prime.autoOffload = {
    enable = true;

    # GTK/Electron applications (work natively with GPU offload)
    applications = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default  # Web browser with GPU acceleration for WebGL, video
      vlc        # Video player with hardware decode
      spotify    # Music player
      ghostty    # Terminal emulator with GPU acceleration (smooth scrolling, better rendering)
    ];

    # Qt applications (need XWayland for proper GPU offload)
    qtApplications = with pkgs; [
      freecad    # 3D CAD (from cad.nix module)
      kicad      # Electronics CAD (from cad.nix module)
    ];

    # Inject NVIDIA environment into Sway session for terminal-launched apps
    swayEnvironment = true;
  };
}

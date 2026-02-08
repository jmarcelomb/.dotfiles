# Desktop profile for graphical NixOS systems
# Includes Sway, audio, bluetooth, and desktop applications
{ pkgs, ... }:

{
  imports = [
    ../modules/sway.nix
    ../modules/audio.nix
    ../modules/bluetooth.nix
    ../modules/gpg.nix
    ../modules/mime.nix
  ];

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # Applications are mostly managed via home-manager
    # System-level packages that need to be here:
    vicinae       # Application launcher
    nautilus      # File manager

    # Wayland utilities
    wl-clipboard
    wlr-randr
  ];

  # Printing support (optional, can be disabled per-host)
  services.printing.enable = true;

  # Display manager for graphical login
  # This is configured in sway.nix via greetd
}

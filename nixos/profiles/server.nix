# Server profile for headless NixOS systems
# Minimal setup without GUI, optimized for server workloads
{ pkgs, ... }:

{
  imports = [
    ../modules/docker.nix
  ];

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = false;  # No GUI
    };
  };

  # Open SSH port
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    htop      # Process monitor
    iotop     # IO monitor
    rsync     # File sync
  ];

  # No need for display manager, audio, or GUI tools
}

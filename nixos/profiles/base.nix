# Base NixOS configuration that all hosts should include
# This provides the foundational setup for any NixOS system
{ pkgs, lib, config, user, hostname, stateVersion, ... }:

{
  # Core system settings
  networking.hostName = hostname;
  system.stateVersion = stateVersion;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes and new Nix commands
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Essential system packages (minimal set)
  environment.systemPackages = with pkgs; [
    git       # Version control
    neovim    # Modern text editor
    wget      # Downloads
    curl      # HTTP client
  ];

  # Set helix as default editor
  environment.variables.EDITOR = "hx";

  # Default shell
  programs.fish.enable = true;

  # Enable nix-ld for running generic Linux binaries
  # This allows running dynamically linked executables intended for generic Linux
  # See: https://nix.dev/permalink/stub-ld
  programs.nix-ld.enable = true;

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Timezone (can be overridden per host)
  time.timeZone = lib.mkDefault "UTC";

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  # Enable sudo
  security.sudo.enable = true;
}

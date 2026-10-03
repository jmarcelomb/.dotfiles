{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Deduplicate identical store paths automatically after every build.
    auto-optimise-store = true;
  };

  # Weekly garbage collection so the store does not fill the disk.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };

  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];
}

{ inputs, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Deduplicate identical store paths automatically after every build.
    auto-optimise-store = true;

    # Make the flake's pinned nixpkgs the one `nix shell nixpkgs#foo` and
    # `nix run nixpkgs#foo` resolve to, instead of a floating registry.
  };

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Weekly garbage collection so the store does not fill the disk.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };

  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];
}

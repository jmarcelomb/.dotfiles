{
  pkgs,
  ...
}:
{
  # Google Workspace CLI (gws) — one CLI for Drive, Gmail, Calendar,
  # Sheets, Admin, etc. First-time auth: `gws auth setup`
  # (the nix-darwin services.googleworkspace-cli module does not exist
  # at our pinned nix-darwin; the nixpkgs package is equivalent)
  environment.systemPackages = [ pkgs.gws ];
}

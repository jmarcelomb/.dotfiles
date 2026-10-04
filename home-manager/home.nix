{
  pkgs,
  lib,
  isServer,
  homeStateVersion,
  user,
  homeDirectory,
  ...
}:
let
  sharedEnv = import ../hosts/shared-env.nix { inherit pkgs; };
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  imports = [
    ./modules/default.nix
    (
      if isDarwin then
        import ./common-home-packages.nix { inherit pkgs isServer; }
      else
        import ./linux-home-packages.nix { inherit pkgs isServer; }
    )
  ]
  # Desktop theming (gtk/papirus/dconf) only on graphical Linux hosts.
  # dconf activation requires a D-Bus session: on headless servers it
  # fails with GDBus.ServiceUnknown and breaks home-manager activation
  # (seen on chakra/caddy 2026-10-04).
  ++ lib.optionals (!isServer && !isDarwin) [ ./modules/theme.nix ];

  home = {
    username = user;
    inherit homeDirectory;
    stateVersion = homeStateVersion;
    sessionVariables = sharedEnv.userVariables;
  };
  programs.home-manager.enable = true;
}

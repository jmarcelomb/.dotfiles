{ pkgs, ... }:
{
  systemVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
  };

  userVariables = {
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = builtins.concatStringsSep ":" [
      "\${XDG_BIN_HOME}"
    ];
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  } // (
    if pkgs.stdenv.isDarwin then {
      # See: https://github.com/NixOS/nixpkgs/issues/390751
      DISPLAY = "nixpkgs-390751";
    } else {}
  );
}
{
  imports = [
    ./zsh.nix
    ./modules/bundle.nix
  ];

  home = {
    username = "jmmb";
    homeDirectory = "/home/jmmb";
    stateVersion = "24.05";
  };
}

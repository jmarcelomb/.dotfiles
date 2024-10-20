{ config, ... }: {
  imports = [
    ./zsh.nix
    ./modules/bundle.nix
  ];

  home = {
    username = "jmmb";
    homeDirectory = "/home/jmmb";
    stateVersion = "24.05";
    file.".local/bin".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/scripts";
  };
}

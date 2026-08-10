{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    rsync
    # neovim is installed via home-manager (see home-manager/modules/neovim.nix)
  ];
}

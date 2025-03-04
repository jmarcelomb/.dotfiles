{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    neovim
    zellij
  ];
}


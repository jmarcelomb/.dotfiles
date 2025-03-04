{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    rsync
    neovim
  ];
}


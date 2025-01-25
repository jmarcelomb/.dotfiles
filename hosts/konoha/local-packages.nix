{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gcc
    git 
    alacritty
  ];
}

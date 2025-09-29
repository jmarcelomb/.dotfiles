{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnupg
  ];
}

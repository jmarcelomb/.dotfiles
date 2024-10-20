{ pkgs, config, ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # defaultCommand = "fd --type f'";
    defaultCommand = "rg --files --hidden";
    defaultOptions = [ "--bind=ctrl-e:up" ];
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.bat = { enable = true; };
  # man with bat
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
  programs.ripgrep = { enable = true; };
  programs.btop = {
    enable = true;
    settings = {
      proc_per_core = true;
      update_ms = 1000;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = pkgs.lib.importTOML "${config.home.homeDirectory}/.dotfiles/.config/starship.toml" ;
  };
  # home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
}

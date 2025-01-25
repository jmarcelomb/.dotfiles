{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    themes = {
      dracula = {
        src = pkgs.fetchFromGitHub {
          owner = "Briles";
          repo = "gruvbox";
          rev = "75407cc80c51814d61beb1df07e380d6f58ad767";
          sha256 = "186rhbljw80psf1l8hyj02ycz1wzxv4rxmbrqr8yvi30165drpay";
        };
        file = "gruvbox (Dark) (Medium).sublime-color-scheme";
      };
    };
  };
}

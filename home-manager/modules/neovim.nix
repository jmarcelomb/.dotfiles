{ pkgs, ... }: {
  # Neovim itself is configured via dotbot-managed LazyVim in ~/.config/nvim.
  # We only install the neovim binary + LSPs here so home-manager doesnt
  # try to write its own init.lua and clobber the LazyVim setup.
  home.packages = with pkgs; [
    neovim
    nixd
  ];
}

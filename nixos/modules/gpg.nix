{ pkgs, ... }:
{
  # services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    # Auto-detection defaults to pinentry-gnome3, which needs GNOME
    # Keyring's D-Bus prompt service (not available under Sway) and can't
    # prompt at all over SSH. pinentry-curses draws the prompt directly in
    # whatever terminal git is run from, so it works both locally and over
    # SSH without needing a display.
    pinentryPackage = pkgs.pinentry-curses;
  };
}

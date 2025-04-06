{ pkgs, self, homeDirectory }:
{
  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      LaunchServices.LSQuarantine = false;
      screencapture.location = "${homeDirectory}/Pictures/screenshots";
      NSGlobalDomain = {
        _HIHideMenuBar = true;
        AppleShowAllExtensions = true;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      dock = {
        autohide = true;
        show-recents = false;
        launchanim = false;
        orientation = "bottom";
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
      };
    };

    activationScripts.extraActivation.text = ''
      softwareupdate --all --install
    '';
  };
  # Set your time zone.
  time.timeZone = "Europe/Lisbon";
}

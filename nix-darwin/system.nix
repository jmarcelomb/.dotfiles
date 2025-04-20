{ self, homeDirectory, ... }:
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

        # ** Keyboard
        # step sliders in UI are:
        # InitialKeyRepeat: 120, 94, 68, 35, 25, 15
        # KeyRepeat: 120, 90, 60, 30, 12, 6, 2
        # default is 25 and 6
        # multiply each by 15 to get milliseconds
        # result: 300ms ti start and 66.6... repeats per second
        # second
        InitialKeyRepeat = 20;
        KeyRepeat = 1;
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
        # make smaller (default 64)
        tilesize = 48;
        wvous-tr-corner = 12;
        wvous-tl-corner = 3;
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

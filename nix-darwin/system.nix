{ self, homeDirectory, ... }:
{
  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      LaunchServices.LSQuarantine = false;
      screencapture.location = "${homeDirectory}/Pictures/screenshots";
      # Keep the login session unlocked when the display sleeps: GUI-bound
      # automation (imsg/AppleScript to Messages.app, screencapture,
      # computer_use) hangs while IOConsoleLocked = Yes. The display still
      # sleeps after 10 min (pmset), only the password prompt is gone.
      # Manual lock (Ctrl+Cmd+Q) still locks.
      screensaver = {
        askForPassword = false;
        askForPasswordDelay = 0;
      };
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
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
      };
      spaces.spans-displays = true;
      NSGlobalDomain."com.apple.keyboard.fnState" = true;
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      dock = {
        autohide = false;
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
  };
  # NOTE: OS/app updates are handled by macOS itself via
  # SoftwareUpdate.AutomaticallyInstallMacOSUpdates above. Do NOT run
  # `softwareupdate` synchronously in activation scripts - it stalls
  # darwin-rebuild for many minutes on every switch.
  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # LaunchAgent to set CapsLock delay on boot
  launchd.user.agents.capslock-delay = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        "{\"CapsLockDelayOverride\":0}"
      ];
      RunAtLoad = true;
    };
  };
}

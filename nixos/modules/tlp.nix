{ config, lib, pkgs, user, ... }:

let
  # Script to toggle between TLP performance and power-saver modes
  tlp-toggle = pkgs.writeShellScriptBin "tlp-toggle" ''
    STATE_FILE="/tmp/tlp-manual-mode"
    
    # Check if we have a manual override set
    if [ -f "$STATE_FILE" ]; then
      MODE=$(cat "$STATE_FILE")
      if [ "$MODE" = "performance" ]; then
        # Switch to power save
        echo "power-saver" > "$STATE_FILE"
        sudo ${pkgs.tlp}/bin/tlp power-saver
        ${pkgs.libnotify}/bin/notify-send "TLP" "Switched to Power Save mode" -i battery-good
      else
        # Switch to performance
        echo "performance" > "$STATE_FILE"
        sudo ${pkgs.tlp}/bin/tlp performance
        ${pkgs.libnotify}/bin/notify-send "TLP" "Switched to Performance mode" -i battery-full-charging
      fi
    else
      # First time - check current CPU governor to determine state
      GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
      if [ "$GOVERNOR" = "performance" ]; then
        # Currently in performance, switch to powersave
        echo "power-saver" > "$STATE_FILE"
        sudo ${pkgs.tlp}/bin/tlp power-saver
        ${pkgs.libnotify}/bin/notify-send "TLP" "Switched to Power Save mode" -i battery-good
      else
        # Currently in powersave, switch to performance
        echo "performance" > "$STATE_FILE"
        sudo ${pkgs.tlp}/bin/tlp performance
        ${pkgs.libnotify}/bin/notify-send "TLP" "Switched to Performance mode" -i battery-full-charging
      fi
    fi
  '';
in
{
  # TLP - Advanced power management for Linux
  services.tlp = {
    enable = true;
    
    settings = {
      # Battery charge thresholds (helps extend battery lifespan)
      # Uncomment and adjust these if your laptop supports it (ThinkPad, some Dell/ASUS)
      # START_CHARGE_THRESH_BAT0 = 40;
      # STOP_CHARGE_THRESH_BAT0 = 80;

      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU boost behavior
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Platform profile (if supported by your hardware)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Runtime power management for PCI(e) devices
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # Battery feature drivers (enable built-in battery optimizations)
      NATACPI_ENABLE = 1;
      TPACPI_ENABLE = 1;
      TPSMAPI_ENABLE = 1;
    };
  };

  # Disable conflicting power management services
  # TLP conflicts with these services
  services.power-profiles-daemon.enable = false;
  
  # Add TLP UI tools and toggle script to system packages
  environment.systemPackages = with pkgs; [
    tlp  # Includes tlp-stat command for viewing statistics
    tlp-toggle  # Custom toggle script
  ];

  # Allow users to run tlp commands without password
  security.sudo.extraRules = [
    {
      users = [ user ];
      commands = [
        {
          command = "${pkgs.tlp}/bin/tlp";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}

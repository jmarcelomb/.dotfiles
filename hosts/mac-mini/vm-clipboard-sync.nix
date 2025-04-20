{ user, homeDirectory, ... }:
{
  # Use user agents for GUI interaction instead of daemons
  launchd.user.agents.vm-clipboard-sync = {
    script = ''
      # Log startup for debugging purposes
      echo "Starting clipboard sync at $(date)" >> /tmp/vm-clipboard-sync.log
      
      # Get the user's display
      export DISPLAY=:0
      
      # Ensure we have access to the user's environment
      . ${homeDirectory}/.zshrc > /dev/null 2>&1 || true
      
      # Run the fswatcher command
      ${homeDirectory}/.cargo/bin/fswatcher \
        '${homeDirectory}/Virtual Machines.localized/Share/clipboard.txt' \
        "cat '${homeDirectory}/Virtual Machines.localized/Share/clipboard.txt' | /usr/bin/pbcopy"
    '';
    serviceConfig = {
      Label = "com.user.vm-clipboard-sync";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive"; # Important for GUI access
      LimitLoadToSessionType = "Aqua"; # Only run in GUI sessions
      StandardOutPath = "/tmp/fswatcher.log";
      StandardErrorPath = "/tmp/fswatcher-error.log";
    };
  };
}
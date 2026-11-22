# Mac Mini - macOS system
{
  self,
  pkgs,
  user,
  homeDirectory,
  system,
  hostname,
  ...
}:
{
  imports = [
    ../../nix-darwin/profiles/base.nix
    ./vm-clipboard-sync.nix
    ./mlx-lm-server.nix
    ./mlx-lm-priority-proxy.nix
    ./mlx-vision-ondemand.nix
    # Dedicated Hindsight extraction server (gemma-4-e2b-it-4bit, :8085)
    ./mlx-hindsight-server.nix
    # LAN bridge exposing the local-models pause state to HA (:8086)
    ./mlx-local-models-bridge.nix
    # Remote dashboard on the NetBird IP (phone app / browser extension)
    ./hermes-dashboard.nix
    # Firecrawl Local (:3002) local web_extract backend, no cloud key
    ./firecrawl-local.nix
    # Hindsight memory daemon (profile hermes, pg0 hindsight-embed-hermes)
    ./hindsight-daemon.nix
    # Hindsight control plane web UI (:19177), loopback only
    ./hindsight-control-plane.nix
    # Nightly pg_dump of the Hindsight pg0 DB (03:30, rotate 10 / 1GB)
    ./hindsight-backup.nix
    # Google Workspace CLI (gws) - admin tooling
    ./googleworkspace.cli.nix
    # Jellyfin media server (native build: VideoToolbox transcoding; media
    # over NFS from the TrueNAS pool)
    ./jellyfin.nix
  ];

  # Host-specific configuration
  # (Most config comes from nix-darwin/profiles/base.nix)

  # Automatic login at boot, so the user LaunchAgents (Hermes gateway, MLX
  # proxies, Hindsight, dashboard) come up with nobody at the console.
  # macOS refuses automatic login while FileVault is on, so this only takes
  # effect after `sudo fdesetup disable` has finished decrypting the disk.
  # This writes the preference only; the stored password comes from the
  # "Automatically log in as" toggle in System Settings or from
  # `sudo sysadminctl -autologin set`.
  system.defaults.loginwindow.autoLoginUser = "jmmb";

  # Lock the console again right after that automatic login: session up,
  # services running, desktop waiting for the password. Only within the first
  # 10 minutes of boot, so a manual logout/login later in the day does not get
  # locked out from under you. Uses the Shortcuts "Lock Screen" action instead
  # of the screensaver, because askForPassword is deliberately false in
  # nix-darwin/system.nix (a screensaver lock would also fire on every display
  # sleep and hang GUI-bound automation: imsg, screencapture, computer_use).
  launchd.user.agents.console-lock = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          sleep 20
          boot=$(/usr/sbin/sysctl -n kern.boottime | sed 's/[^0-9]*\([0-9]\{1,\}\).*/\1/')
          [ $(( $(/bin/date +%s) - boot )) -lt 600 ] && exec /usr/bin/shortcuts run 'Bloquear ecrã'
          exit 0
        ''
      ];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
}

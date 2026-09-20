{ pkgs, user, homeDirectory, ... }:
{
  # Always-on DSH web GUI on this machine, plus a NetBird-only L4 proxy so
  # other devices in the NetBird network can reach it. dsh itself stays
  # loopback-bound (0.0.0.0 is intentionally unsupported by dsh web).
  # Secrets and NETBIRD_IP live in ${homeDirectory}/.dsh/mcp-env (untracked;
  # template: .dsh/mcp-env.example in the dotfiles repo).
  launchd.user.agents = {
    dsh-web = {
      serviceConfig = {
        Label = "com.user.dsh-web";
        ProgramArguments = [ "${homeDirectory}/scripts/dsh-web" ];
        RunAtLoad = true;
        KeepAlive = true;
        LimitLoadToSessionType = "Aqua";
        StandardOutPath = "${homeDirectory}/Library/Logs/dsh-web/out.log";
        StandardErrorPath = "${homeDirectory}/Library/Logs/dsh-web/err.log";
      };
    };
    dsh-web-netbird = {
      # Pure TCP pass-through (WebSocket/SSE safe) from the NetBird overlay
      # address to the loopbound dsh web. Binds ONLY the NetBird IP, so the
      # LAN and public interfaces stay closed. KeepAlive retries until the
      # NetBird interface (or mcp-env) is ready.
      script = ''
        [ -f "${homeDirectory}/.dsh/mcp-env" ] || exit 1
        . "${homeDirectory}/.dsh/mcp-env"
        if [ -z "''${NETBIRD_IP:-}" ]; then
          echo "NETBIRD_IP not set in ${homeDirectory}/.dsh/mcp-env; will retry" >&2
          exit 1
        fi
        exec ${pkgs.socat}/bin/socat \
          TCP-LISTEN:3080,bind="''${NETBIRD_IP}",fork,reuseaddr \
          TCP:127.0.0.1:3080
      '';
      serviceConfig = {
        Label = "com.user.dsh-web-netbird";
        RunAtLoad = true;
        KeepAlive = true;
        LimitLoadToSessionType = "Aqua";
        StandardOutPath = "${homeDirectory}/Library/Logs/dsh-web/netbird-out.log";
        StandardErrorPath = "${homeDirectory}/Library/Logs/dsh-web/netbird-err.log";
      };
    };
  };

  # LaunchAgents' log directory must exist before launchd opens the files.
  system.activationScripts.dshWebLogs.text = ''
    mkdir -p "${homeDirectory}/Library/Logs/dsh-web"
    chmod 700 "${homeDirectory}/Library/Logs/dsh-web"
  '';
}

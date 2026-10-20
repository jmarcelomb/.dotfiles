# Priority proxy in front of mlx_lm.server.
#
# Binds 8080 (the port Hermes chat and the Hindsight daemon both target)
# and forwards to mlx_lm on 8083. Requests carrying the background API key
# (only Hindsight's retain role sends it, via
# HINDSIGHT_API_RETAIN_LLM_API_KEY) are held while any priority request is
# in flight; everything else - Hermes chat, Hindsight recall/reflect,
# consolidation - forwards immediately. mlx_lm serves one request at a
# time regardless, so this only changes who waits: background never
# delays priority, and a Hermes session's local-model call never sits
# behind the retain backlog.
#
# Deadlock safety: priority requests are never held, so held background
# requests always drain once priority traffic stops. If a retain call is
# held past Hindsight's LLM timeout, Hindsight times it out and
# reschedules - fail-safe, not deadlock.
#
# Pure Python stdlib; no venv. Streaming (SSE) is relayed chunk by chunk.
{ pkgs, user, homeDirectory, ... }:

let
  proxyScript = pkgs.writeText "mlx-lm-priority-proxy.py" ''
    ${builtins.readFile ./mlx-lm-priority-proxy.py}
  '';
in
{
  launchd.user.agents.mlx-lm-priority-proxy = {
    script = ''
      exec /usr/bin/python3 ${proxyScript}
    '';
    serviceConfig = {
      Label = "com.user.mlx-lm-priority-proxy";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${homeDirectory}/Library/Logs/mlx-lm/proxy.log";
      StandardErrorPath = "${homeDirectory}/Library/Logs/mlx-lm/proxy.log";
    };
  };
}

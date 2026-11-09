# Hindsight control plane (web UI) as a launchd user agent.
#
# The control plane is a Node app with no PyPI distribution, so it cannot be
# run through uvx like the daemon; npx against the pinned npm version is the
# only declarative-ish option. The npx cache in ~/.npm/_npx keeps the first
# launch after a bump from depending on a live registry.
#
# KEEP THE VERSION IN STEP WITH hindsight-daemon.nix. A control plane older
# than the API still serves pages but its bank list comes back empty, which
# reads as "create a new bank" in the UI while the API happily returns the
# real banks.
#
# Bound to loopback on purpose: the UI exposes every memory in the bank and
# has no auth unless HINDSIGHT_CP_ACCESS_KEY is set. Flip `host` to "0.0.0.0"
# (and set an access key) if it must be reachable from another device.
{ pkgs, homeDirectory, ... }:

let
  cfg = {
    host = "127.0.0.1";
    port = 19177;
    version = "1.2.0";
    apiUrl = "http://127.0.0.1:9177";
    logDir = "${homeDirectory}/.hindsight/profiles";
    node = pkgs.nodejs;
  };
in
{
  launchd.user.agents.hindsight-control-plane = {
    script = ''
      # npx and the package bin it spawns both start with `#!/usr/bin/env node`,
      # so node has to be on PATH. launchd hands the job a bare /usr/bin:/bin,
      # which made every run die with "env: node: No such file or directory".
      export PATH="${cfg.node}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
      exec ${cfg.node}/bin/npx --yes @vectorize-io/hindsight-control-plane@${cfg.version} --port ${toString cfg.port} --hostname ${cfg.host} --api-url ${cfg.apiUrl}
    '';
    serviceConfig = {
      Label = "io.hindsight.control-plane";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/control-plane.log";
      StandardErrorPath = "${cfg.logDir}/control-plane.log";
    };
  };
}

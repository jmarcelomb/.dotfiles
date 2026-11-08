# On-demand local vision server, as a launchd user agent.
#
# A tiny stdlib-only rust proxy (hosts/mac-mini/vision-proxy, built here
# via rustPlatform.buildRustPackage) listens on 127.0.0.1:8081 and speaks
# the OpenAI API. On the first request it starts mlx_vlm.server on 8082
# with a small multimodal model, and stops that backend after idleSeconds
# without traffic, so the vision model's weights only occupy memory while
# vision is actually used. Health probes (GET /v1/models) are answered
# statically and never trigger a load.
#
# Pause-aware (scripts/local-models): while the pause flag exists,
# requests get a 503 instead of cold-starting the VLM, and a running
# backend is force-unloaded within one watchdog cycle (~15s).
#
# Local dev builds need RUSTFLAGS="-C linker=/usr/bin/cc" (zig cc, the
# system linker, cannot find -liconv); the nix build is unaffected.
#
# Hermes aux.vision points at http://127.0.0.1:8081/v1 with model
# mlx-community/Qwen3.5-4B-4bit (see ~/hermes/hermes/config.yaml).
# First request after idle pays a ~10s model load; warm requests ~0.5s.
{ pkgs, user, homeDirectory, ... }:

let
  visionProxy = pkgs.rustPlatform.buildRustPackage {
    pname = "vision-proxy";
    version = "1.0.0";
    # Keep the cargo target dir (hundreds of MB) out of the store source.
    src = pkgs.lib.cleanSourceWith {
      src = pkgs.lib.cleanSource ./vision-proxy;
      filter = path: _type: baseNameOf path != "target";
    };
    cargoLock.lockFile = ./vision-proxy/Cargo.lock;
  };
  cfg = {
    host = "127.0.0.1";
    port = 8081;
    # Unload the vision backend after this many seconds without traffic.
    idleSeconds = 600;
    logDir = "${homeDirectory}/Library/Logs/mlx-vision";
    maxLogSizeMB = 5;
    maxArchives = 2;
  };
in
{
  launchd.user.agents.mlx-vision-ondemand = {
    script = ''
      mkdir -p ${cfg.logDir}
      exec ${visionProxy}/bin/vision-proxy
    '';
    serviceConfig = {
      Label = "com.user.mlx-vision-ondemand";
      RunAtLoad = true;
      KeepAlive = true; # restart on crash
      ProcessType = "Background";
      EnvironmentVariables = {
        MLX_VISION_IDLE_SECONDS = toString cfg.idleSeconds;
      };
      StandardOutPath = "${cfg.logDir}/launchd.out";
      StandardErrorPath = "${cfg.logDir}/launchd.out";
    };
  };

  # Rotate logs (the proxy and backend write proxy.log / server.log inside
  # logDir; launchd.out catches process-level stderr).
  environment.etc."newsyslog.d/mlx-vision.conf".text = ''
    # logfilename                           owner:group  mode  count  size  when  flags
    ${cfg.logDir}/proxy.log                 ${user}:staff 644  ${toString cfg.maxArchives}  ${
      toString (cfg.maxLogSizeMB * 1024)
    }  *  J
    ${cfg.logDir}/server.log                ${user}:staff 644  ${toString cfg.maxArchives}  ${
      toString (cfg.maxLogSizeMB * 1024)
    }  *  J
    ${cfg.logDir}/launchd.out               ${user}:staff 644  ${toString cfg.maxArchives}  ${
      toString (cfg.maxLogSizeMB * 1024)
    }  *  J
  '';
}

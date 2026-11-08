# LAN bridge for the local-models pause flag (axum, see local-models-bridge/).
# Home Assistant's REST switch polls GET /state and toggles via POST, so the
# pause is visible and controllable from dashboards and the mobile app.
# Requires no sudo and no SSH: HA -> http://192.168.0.69:8086/state with the
# shared HASS_TOKEN as Bearer. Local dev builds need
# RUSTFLAGS="-C linker=/usr/bin/cc" (zig cc, the system linker, cannot find
# -liconv); the nix build is unaffected. Surface in HA configuration.yaml:
#
#   switch:
#     - platform: rest
#       name: Modelos locais
#       resource: http://192.168.0.69:8086/state
#       body_on: '{"state": "running"}'
#       body_off: '{"state": "paused"}'
#       is_on_template: "{{ value_json.paused == false }}"
#       headers:
#         Content-Type: application/json
#         Authorization: !secret local_models_bearer
#
# with local_models_bearer: "Bearer <HASS_TOKEN>" in the instance secrets.yaml.
{
  pkgs,
  homeDirectory,
  ...
}:

let
  bridge = pkgs.rustPlatform.buildRustPackage {
    pname = "local-models-bridge";
    version = "1.0.0";
    # Keep the cargo target dir (hundreds of MB) out of the store source.
    src = pkgs.lib.cleanSourceWith {
      src = pkgs.lib.cleanSource ./local-models-bridge;
      filter = path: _type: baseNameOf path != "target";
    };
    cargoLock.lockFile = ./local-models-bridge/Cargo.lock;
  };
in
{
  launchd.user.agents.mlx-local-models-bridge = {
    script = ''
      exec ${bridge}/bin/local-models-bridge
    '';
    serviceConfig = {
      Label = "com.user.mlx-local-models-bridge";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${homeDirectory}/Library/Logs/mlx-lm/bridge.log";
      StandardErrorPath = "${homeDirectory}/Library/Logs/mlx-lm/bridge.log";
    };
  };
}

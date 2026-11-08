# LAN bridge for the local-models pause flag (see mlx-local-models-bridge.py).
# Home Assistant's REST switch polls GET /state and toggles via POST, so the
# pause is visible and controllable from dashboards and the mobile app.
# Requires no sudo and no SSH: HA -> http://<mini>:8086/state with the shared
# HASS_TOKEN as Bearer. Surface in HA configuration.yaml:
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
  user,
  homeDirectory,
  ...
}:

let
  bridgeScript = pkgs.writeText "mlx-local-models-bridge.py" ''
    ${builtins.readFile ./mlx-local-models-bridge.py}
  '';
in
{
  launchd.user.agents.mlx-local-models-bridge = {
    script = ''
      exec /usr/bin/python3 ${bridgeScript}
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

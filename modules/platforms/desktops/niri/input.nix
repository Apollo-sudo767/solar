{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      input = {
        mod-key = "Alt";
        mod-key-nested = "Super";

        touchpad = {
          tap = true;
          dwt = true;
          natural-scroll = true;
          accel-speed = 0.2;
          accel-profile = "adaptive";
          click-method = "clickfinger";
        };

        touch = {
          map-to-output = "eDP-1";
        };

        tablet = {
          map-to-output = "eDP-1";
        };
      };

      gestures = {
        dnd-edge-workspace-switch = { };
      };
    };
  };
}

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
        touchpad = {
          tap = { };
          dwt = { };
          natural-scroll = { };
          accel-speed = 0.2;
          accel-profile = "adaptive";
          click-method = "clickfinger";
        };

        mouse = {
          accel-profile = "flat";
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
        hot-corners.off = { };
      };
    };
  };
}

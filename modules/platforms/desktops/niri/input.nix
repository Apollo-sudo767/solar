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
        focus-follows-mouse._props = {
          max-scroll-amount = "0%";
        };
        warp-mouse-to-focus = { };
        workspace-auto-back-and-forth = { };

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
      };

      gestures = {
        dnd-edge-workspace-switch = { };
        hot-corners.off = { };
      };

      cursor = {
        hide-when-typing = { };
        hide-after-inactive-ms = 3000;
      };
    };
  };
}

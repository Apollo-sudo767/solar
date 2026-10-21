# modules/hardware/input/trackpad.nix
# ============================================================================
# Multi-Touch Trackpad Configuration (`libinput`)
# ============================================================================
# Enables tap-to-click, natural scrolling, and middle-click emulation via
# `services.libinput`. Enabled automatically by `modules/suites/laptop.nix`.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.hardware.input.trackpad;
in
{
  options.myFeatures.hardware.input.trackpad.enable = lib.mkEnableOption "Trackpad Settings";

  config = lib.mkIf cfg.enable {
    services.libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
        middleEmulation = true;
      };
    };
  };
}

{ config, lib, ... }:

let
  cfg = config.myFeatures.hardware.trackpad;
in
{
  options.myFeatures.hardware.trackpad.enable = lib.mkEnableOption "Trackpad Settings";

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

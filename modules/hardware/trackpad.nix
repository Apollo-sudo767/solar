{ config, lib, isDarwin, ... }: # <-- Add isDarwin

let
  cfg = config.myFeatures.hardware.trackpad;
in
{
  options.myFeatures.hardware.trackpad.enable = lib.mkEnableOption "Trackpad Settings";

  # Shield everything
  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    services.libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
        middleEmulation = true;
      };
    };
  });
}

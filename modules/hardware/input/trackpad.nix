{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.hardware.input.trackpad;
in
{
  options.myFeatures.hardware.input.trackpad.enable = lib.mkEnableOption "Trackpad Settings";

  # Shield everything
  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          naturalScrolling = true;
          middleEmulation = true;
        };
      };
    }
  );
}

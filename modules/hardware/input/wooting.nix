{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.hardware.input.wooting;
in
{
  options.myFeatures.hardware.input.wooting.enable = lib.mkEnableOption "Wooting Keyboard Support";

  # Shield everything
  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      hardware.wooting.enable = true;

      environment.systemPackages = [
        pkgs.wootility
        pkgs.wooting-udev-rules
      ];
    }
  );
}

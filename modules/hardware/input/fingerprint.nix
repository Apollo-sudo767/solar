{
  config,
  lib,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.hardware.input.fingerprint;
in
{
  options.myFeatures.hardware.input.fingerprint.enable =
    lib.mkEnableOption "Fingerprint Sensor Support";

  # Shield everything
  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.fprintd.enable = true;
      security.pam.services.sudo.fprintAuth = true;
    }
  );
}

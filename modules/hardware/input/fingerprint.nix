# modules/hardware/input/fingerprint.nix
# ============================================================================
# Biometric Fingerprint Reader (`fprintd`)
# ============================================================================
# Enables the `fprintd` daemon and PAM integration for `sudo` authentication.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.hardware.input.fingerprint;
in
{
  options.myFeatures.hardware.input.fingerprint.enable =
    lib.mkEnableOption "Fingerprint Sensor Support";

  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;
    security.pam.services.sudo.fprintAuth = true;
  };
}

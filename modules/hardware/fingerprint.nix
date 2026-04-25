{ config, lib, pkgs, ... }: # <-- Add pkgs.stdenv.isDarwin

let
  cfg = config.myFeatures.hardware.fingerprint;
in
{
  options.myFeatures.hardware.fingerprint.enable = lib.mkEnableOption "Fingerprint Sensor Support";

  # Shield everything
  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;
    security.pam.services.sudo.fprintAuth = true;
  };
}

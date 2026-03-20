{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.fingerprint;
in
{
  options.myFeatures.hardware.fingerprint.enable = lib.mkEnableOption "Fingerprint Sensor Support";

  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;
    
    # Allows you to use your fingerprint for 'sudo' in the terminal
    security.pam.services.sudo.fprintAuth = true;
  };
}

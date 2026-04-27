{ config, lib, pkgs, inputs, ... }: # Added pkgs.stdenv.isDarwin

let
  cfg = config.myFeatures.services.hardware.firmware;
in
{
  options.myFeatures.services.hardware.firmware = {
    enable = lib.mkEnableOption "Enable Firmware Updates";
  };

  # --- CONFIG ---
  # Shield the Linux-only firmware service from the macOS evaluator
  config = lib.mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}

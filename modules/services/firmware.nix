{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.firmware;
in
{
  options.myFeatures.services.firmware = {
    enable = lib.mkEnableOption "Enable Firmware Updates";
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
  config = lib.mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}

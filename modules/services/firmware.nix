{ config, lib, pkgs, inputs, isDarwin, ... }: # Added isDarwin

let
  cfg = config.myFeatures.services.firmware;
in
{
  options.myFeatures.services.firmware = {
    enable = lib.mkEnableOption "Enable Firmware Updates";
  };

  # --- CONFIG ---
  # Shield the Linux-only firmware service from the macOS evaluator
  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    services.fwupd.enable = true;
  });
}

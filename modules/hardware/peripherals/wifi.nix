{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.hardware.peripherals.wifi;
in
{
  options.myFeatures.hardware.peripherals.wifi = {
    enable = lib.mkEnableOption "Enables Wifi Services";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
    };
  };
}

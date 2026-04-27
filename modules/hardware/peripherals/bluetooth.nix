{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.hardware.peripherals.bluetooth;
in
{
  options.myFeatures.hardware.peripherals.bluetooth = {
    enable = lib.mkEnableOption "Enables bluetooth services";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
    };
    services.blueman.enable = true;
    environment.systemPackages = [ pkgs.bluez ];
  };
}

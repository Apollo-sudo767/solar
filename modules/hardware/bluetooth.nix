{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.hardware.bluetooth;
in
{
  options.myFeatures.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enables bluetooth services"
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
    environment.systemPackages = [ pkgs.bluez ];
  };
}

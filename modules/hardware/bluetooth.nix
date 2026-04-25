{ config, lib, pkgs, inputs, isDarwin, ... }:

let
  cfg = config.myFeatures.hardware.bluetooth;
in
{
  options.myFeatures.hardware.bluetooth = {
    enable = lib.mkEnableOption "Enables bluetooth services";
  };

  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    hardware.bluetooth = {
      enable = true;
    };
    services.blueman.enable = true;
    environment.systemPackages = [ pkgs.bluez ];
  });
}

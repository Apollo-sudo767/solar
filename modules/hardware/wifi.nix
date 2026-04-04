{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.hardware.wifi;
in
{
  options.myFeatures.hardware.wifi = {
    enable = lib.mkEnableOption "Enables Wifi Services";
  };

  config = lib.mkIf cfg.enable {  
    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
     };

     networking.wireless.iwd = {
       enable = true;
       settings = {
         General = {
         EnableNetworkConfiguration = true;
       };
     };
   };
 };
}

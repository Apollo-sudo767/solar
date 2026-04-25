{ config, lib, pkgs, isDarwin, ... }: # <-- Add isDarwin

let
  cfg = config.myFeatures.hardware.wifi;
in
{
  options.myFeatures.hardware.wifi = {
    enable = lib.mkEnableOption "Enables Wifi Services";
  };

  # Shield everything
  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {  
    networking.networkmanager = {
      enable = true;
     };
   });
}

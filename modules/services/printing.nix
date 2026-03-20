{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.printing;
in
{
  options.myFeatures.services.printing.enable = lib.mkEnableOption "CUPS Printing Support";

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      # If you find a specific printer at Mizzou that needs drivers:
      # drivers = [ pkgs.gutenprint ]; 
    };
    
    # Allows discovery of network printers (like in the library)
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}

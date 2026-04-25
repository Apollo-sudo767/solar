{ config, lib, isDarwin, ... }:

let
  cfg = config.myFeatures.services.udisks2;
in
{
  options.myFeatures.services.udisks2 = {
    enable = lib.mkEnableOption "Udisks2 and GVFS for automounting";
  };

  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    services.udisks2.enable = true; 
    services.dbus.enable = true; 
    services.gvfs.enable = true; # Needed for Trash/Network in file managers [cite: 16]
  });
}

{ config, lib, ... }:

let
  cfg = config.myFeatures.services.flatpak;
in
{
  options.myFeatures.services.flatpak = {
    enable = lib.mkEnableOption "Flatpak Support";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true; 
    xdg.portal.enable = true; # Required for Flatpak integration [cite: 32]
  };
}

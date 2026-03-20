{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.kde;
in
{
  options.myFeatures.systems.kde = {
    enable = lib.mkEnableOption "KDE Plasma 6 Desktop";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true; 
    services.desktopManager.plasma6.enable = true; 

    environment.systemPackages = with pkgs; [
      kdePackages.krunner
      kdePackages.plasma-nm
      kdePackages.plasma-pa
      kdePackages.dolphin
      kdePackages.spectacle
      kdePackages.ark
    ]; 

    # Ensure Plasma uses its specific portal
    xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ]; 
  };
}

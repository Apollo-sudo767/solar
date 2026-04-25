{ config, lib, pkgs, isDarwin, ... }:

let
  cfg = config.myFeatures.services.xdgPortals;
in
{
  options.myFeatures.services.xdgPortals = {
    enable = lib.mkEnableOption "XDG Portals for Wayland/Desktop";
  };

  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    xdg = {
      autostart.enable = true; 
      portal = {
        enable = true; 
        xdgOpenUsePortal = true; 
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome 
          xdg-desktop-portal-gtk 
          kdePackages.xdg-desktop-portal-kde 
          xdg-desktop-portal-wlr 
        ];
        config = {
          common.default = [ "gtk" ]; 
          niri.default = [ "gnome" "gtk" ]; 
          plasma.default = [ "kde" "gtk" ]; 
        };
      };
    };
  });
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.xdgPortals;
in
{
  options.myFeatures.systems.xdgPortals = {
    enable = lib.mkEnableOption "XDG Portals for Wayland/Desktop";
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      autostart.enable = true; 
      portal = {
        enable = true; 
        xdgOpenUsePortal = true; 
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome 
          xdg-desktop-portal-gtk 
          xdg-desktop-portal-kde 
          xdg-desktop-portal-wlr 
        ];
        config = {
          common.default = [ "gtk" ]; 
          niri.default = [ "gnome" "gtk" ]; 
          plasma.default = [ "kde" "gtk" ]; 
        };
      };
    };
  };
}

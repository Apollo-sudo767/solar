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
      autostart.enable = true; [cite: 9]
      portal = {
        enable = true; [cite: 10]
        xdgOpenUsePortal = true; [cite: 10]
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome [cite: 11]
          xdg-desktop-portal-gtk [cite: 11]
          xdg-desktop-portal-kde [cite: 11]
          xdg-desktop-portal-wlr [cite: 11]
        ];
        config = {
          common.default = [ "gtk" ]; [cite: 12]
          niri.default = [ "gnome" "gtk" ]; [cite: 13]
          plasma.default = [ "kde" "gtk" ]; [cite: 13]
        };
      };
    };
  };
}

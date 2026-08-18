{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.services.system.xdgPortals;
in
{
  options.myFeatures.services.system.xdgPortals = {
    enable = lib.mkEnableOption "XDG Portals for Wayland/Desktop";
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals =
          with pkgs;
          [ xdg-desktop-portal-gtk ]
          ++ lib.optional (config.myFeatures.platforms.desktops.gnome.enable or false
          ) xdg-desktop-portal-gnome
          ++ lib.optional (config.myFeatures.platforms.desktops.kde.enable or false
          ) kdePackages.xdg-desktop-portal-kde
          ++ lib.optional (config.myFeatures.platforms.desktops.cosmic.enable or false
          ) xdg-desktop-portal-cosmic;
        config = {
          common.default = [ "gtk" ];
          niri.default = [ "gtk" ];
          plasma.default = [
            "kde"
            "gtk"
          ];
          cosmic.default = [
            "cosmic"
            "gtk"
          ];
        };
      };
    };
  };
}

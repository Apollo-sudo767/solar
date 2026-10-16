{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.labwc;
in
{
  options.myFeatures.suites.desktops.labwc = {
    enable = lib.mkEnableOption "Labwc Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.labwc.enable = true;
        addons = {
          waybar.enable = lib.mkDefault true;
        };
      };

      programs.utilities = {
        filemanager = {
          nautilus.enable = lib.mkDefault true;
          yazi.enable = lib.mkDefault true;
        };
        appstore.gnome-software.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        system.xdgPortals.enable = lib.mkDefault true;
      };
    };
  };
}

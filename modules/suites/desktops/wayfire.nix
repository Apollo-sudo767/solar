{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.wayfire;
in
{
  options.myFeatures.suites.desktops.wayfire = {
    enable = lib.mkEnableOption "Wayfire Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.wayfire.enable = true;
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

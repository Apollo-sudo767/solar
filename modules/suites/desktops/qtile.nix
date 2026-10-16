{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.qtile;
in
{
  options.myFeatures.suites.desktops.qtile = {
    enable = lib.mkEnableOption "Qtile Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.qtile.enable = true;
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

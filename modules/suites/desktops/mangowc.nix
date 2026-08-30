{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.mangowc;
in
{
  options.myFeatures.suites.desktops.mangowc = {
    enable = lib.mkEnableOption "MangoWC Desktop Suite (MangoWC + ReGreet + Nautilus + Yazi + Audio + Portals)";
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms = {
        desktops.mangowc.enable = true;
        addons = {
          swayosd.enable = lib.mkDefault true;
        };
      };

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nautilus";
        yazi.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        system.xdgPortals.enable = lib.mkDefault true;
      };
    };
  };
}

{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.sway;
in
{
  options.myFeatures.suites.desktops.sway = {
    enable = lib.mkEnableOption "Sway Desktop Suite (Sway + Waybar + SwayNC + ReGreet + Nautilus + Yazi + Audio + Portals)";
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms = {
        desktops.sway.enable = true;
        addons = {
          waybar.enable = lib.mkDefault true;
          swaync.enable = lib.mkDefault true;
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

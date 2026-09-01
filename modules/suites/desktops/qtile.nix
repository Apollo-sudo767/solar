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

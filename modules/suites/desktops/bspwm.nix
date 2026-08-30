{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.bspwm;
in
{
  options.myFeatures.suites.desktops.bspwm = {
    enable = lib.mkEnableOption "Bspwm Desktop Suite";
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms = {
        desktops.bspwm.enable = true;
      };

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nautilus";
        yazi.enable = lib.mkDefault true;
      };

      services.multimedia.audio.enable = lib.mkDefault true;
    };
  };
}

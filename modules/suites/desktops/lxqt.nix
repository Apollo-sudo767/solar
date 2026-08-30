{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.lxqt;
in
{
  options.myFeatures.suites.desktops.lxqt = {
    enable = lib.mkEnableOption "LXQt Desktop Suite";
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms.desktops.lxqt.enable = true;

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "pcmanfm";
        yazi.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

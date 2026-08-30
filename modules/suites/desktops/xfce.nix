{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.xfce;
in
{
  options.myFeatures.suites.desktops.xfce = {
    enable = lib.mkEnableOption "XFCE Desktop Suite";
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms.desktops.xfce.enable = true;

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "thunar";
        yazi.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

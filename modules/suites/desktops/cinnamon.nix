{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.cinnamon;
in
{
  options.myFeatures.suites.desktops.cinnamon = {
    enable = lib.mkEnableOption "Cinnamon Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms.desktops.cinnamon.enable = true;

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nemo";
        yazi.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

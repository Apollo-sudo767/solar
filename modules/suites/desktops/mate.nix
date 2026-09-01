{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.mate;
in
{
  options.myFeatures.suites.desktops.mate = {
    enable = lib.mkEnableOption "MATE Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms.desktops.mate.enable = true;

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nautilus";
        yazi.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

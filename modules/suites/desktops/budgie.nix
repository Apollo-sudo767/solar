{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.budgie;
in
{
  options.myFeatures.suites.desktops.budgie = {
    enable = lib.mkEnableOption "Budgie Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms.desktops.budgie.enable = true;

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

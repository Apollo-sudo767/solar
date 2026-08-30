{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.plasma;
in
{
  options.myFeatures.suites.desktops.plasma = {
    enable = lib.mkEnableOption "KDE Plasma Desktop Suite";
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms.desktops.kde.enable = true;

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "dolphin";
        yazi.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

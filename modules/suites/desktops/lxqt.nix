# modules/suites/desktops/lxqt.nix
#
# Desktop suite enabling the LXQt desktop environment alongside PCManFM,
# Yazi, KDE Discover, PipeWire audio, and CUPS printing.
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

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms.desktops.lxqt.enable = true;

      programs.utilities = {
        filemanager = {
          pcmanfm.enable = lib.mkDefault true;
          yazi.enable = lib.mkDefault true;
        };
        appstore.discover.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

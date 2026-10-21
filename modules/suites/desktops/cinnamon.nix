# modules/suites/desktops/cinnamon.nix
#
# Desktop suite enabling the Cinnamon desktop environment alongside Nemo,
# Yazi, GNOME Software, PipeWire audio, and CUPS printing.
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

      programs.utilities = {
        filemanager = {
          nemo.enable = lib.mkDefault true;
          yazi.enable = lib.mkDefault true;
        };
        appstore.gnome-software.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

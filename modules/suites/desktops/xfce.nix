# modules/suites/desktops/xfce.nix
#
# Desktop suite enabling the XFCE desktop environment alongside Thunar,
# Yazi, GNOME Software, PipeWire audio, and CUPS printing.
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

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms.desktops.xfce.enable = true;

      programs.utilities = {
        filemanager = {
          thunar.enable = lib.mkDefault true;
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

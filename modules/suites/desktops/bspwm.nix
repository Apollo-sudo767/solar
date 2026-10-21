# modules/suites/desktops/bspwm.nix
#
# Desktop suite enabling Bspwm alongside Nautilus, Yazi, GNOME Software,
# and PipeWire audio.
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

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.bspwm.enable = true;
      };

      programs.utilities = {
        filemanager = {
          nautilus.enable = lib.mkDefault true;
          yazi.enable = lib.mkDefault true;
        };
        appstore.gnome-software.enable = lib.mkDefault true;
      };

      services.multimedia.audio.enable = lib.mkDefault true;
    };
  };
}

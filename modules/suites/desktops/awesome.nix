# modules/suites/desktops/awesome.nix
#
# Desktop suite enabling AwesomeWM alongside Nautilus, Yazi, GNOME Software,
# and PipeWire audio.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.awesome;
in
{
  options.myFeatures.suites.desktops.awesome = {
    enable = lib.mkEnableOption "AwesomeWM Desktop Suite";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.awesome.enable = true;
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

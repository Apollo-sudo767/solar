{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.i3;
in
{
  options.myFeatures.suites.desktops.i3 = {
    enable = lib.mkEnableOption "i3 X11 Desktop Suite (i3 + Picom + ReGreet + Nautilus + Yazi + Audio)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.i3.enable = true;
        addons = {
        };
      };

      programs.utilities = {
        filemanager = {
          nautilus.enable = lib.mkDefault true;
          yazi.enable = lib.mkDefault true;
        };
        appstore.gnome-software.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
      };
    };
  };
}

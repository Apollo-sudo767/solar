# modules/suites/desktops/i3.nix
# ============================================================================
# i3 X11 Tiling Window Manager Desktop Suite
# ============================================================================
# Composite X11 desktop suite enabling the i3 window manager (with i3status,
# picom, rofi/dmenu), Nautilus + Yazi file managers, GNOME Software, and
# PipeWire audio.
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
    enable = lib.mkEnableOption "i3 X11 Desktop Suite (i3 + Picom + Nautilus + Yazi + Audio)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms.desktops.i3.enable = true;

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

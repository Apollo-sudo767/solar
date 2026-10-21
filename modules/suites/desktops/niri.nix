# modules/suites/desktops/niri.nix
# ============================================================================
# Niri Scrollable-Tiling Desktop Suite
# ============================================================================
# Composite desktop suite for Niri. Enables the Niri compositor, keybindings,
# SwayOSD overlay, desktop shell (`noctalia-v5` by default, or `waybar`),
# Nautilus + Yazi file managers, GNOME Software, PipeWire audio, and XDG portals.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.niri;
in
{
  options.myFeatures.suites.desktops.niri = {
    enable = lib.mkEnableOption "Niri Desktop Suite (Niri + Keybinds + Shell + Nautilus + Yazi + Audio + Portals)";
    shell = lib.mkOption {
      type = lib.types.enum [
        "noctalia-v5"
        "waybar"
        "none"
      ];
      default = "noctalia-v5";
      description = "Desktop shell/bar to enable with the Niri suite";
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.niri.enable = true;
        styling.niriKeybinds.enable = lib.mkDefault true;
        addons = {
          swayosd.enable = lib.mkDefault true;
          noctalia-v5.enable = lib.mkIf (cfg.shell == "noctalia-v5") true;
          waybar.enable = lib.mkIf (cfg.shell == "waybar") true;
          swaync.enable = lib.mkIf (cfg.shell == "waybar") true;
        };
      };

      programs.utilities = {
        filemanager = {
          nautilus.enable = lib.mkDefault true;
          yazi.enable = lib.mkDefault true;
        };
        appstore = {
          gnome-software.enable = lib.mkDefault true;
        };
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        system.xdgPortals.enable = lib.mkDefault true;
      };
    };
  };
}

{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.hyprland;
in
{
  options.myFeatures.suites.desktops.hyprland = {
    enable = lib.mkEnableOption "Hyprland Desktop Suite (Hyprland + Waybar + SwayNC + ReGreet + Nautilus + Yazi + Audio + Portals)";

    addons = {
      waybar = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Waybar status bar.";
      };
      swaync = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable SwayNC notification center.";
      };
      swayosd = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable SwayOSD on-screen display for volume and brightness.";
      };
    };

    filemanager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Nautilus file manager.";
      };
      yazi = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Yazi terminal file manager.";
      };
    };

    audio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable PipeWire low-latency audio.";
      };
    };

    xdgPortals = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable XDG desktop portals.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.hyprland.enable = true;
        addons = {
          waybar.enable = lib.mkIf cfg.addons.waybar (lib.mkDefault true);
          swaync.enable = lib.mkIf cfg.addons.swaync (lib.mkDefault true);
          swayosd.enable = lib.mkIf cfg.addons.swayosd (lib.mkDefault true);
        };
      };

      programs.utilities.filemanager = lib.mkIf cfg.filemanager.enable {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nautilus";
        yazi.enable = lib.mkIf cfg.filemanager.yazi (lib.mkDefault true);
      };

      services = {
        multimedia.audio.enable = lib.mkIf cfg.audio.enable (lib.mkDefault true);
        system.xdgPortals.enable = lib.mkIf cfg.xdgPortals.enable (lib.mkDefault true);
      };
    };
  };
}

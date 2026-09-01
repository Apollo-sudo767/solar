{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.mangowc;
in
{
  options.myFeatures.suites.desktops.mangowc = {
    enable = lib.mkEnableOption "MangoWC Desktop Suite (MangoWC + ReGreet + Nautilus + Yazi + Audio + Portals)";

    addons = {
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
        desktops.mangowc.enable = true;
        addons = {
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

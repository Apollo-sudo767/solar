{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.gnome;
in
{
  options.myFeatures.suites.desktops.gnome = {
    enable = lib.mkEnableOption "GNOME Desktop Suite";

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

    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable CUPS printing daemon.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms.desktops.gnome.enable = true;

      programs.utilities.filemanager = lib.mkIf cfg.filemanager.enable {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nautilus";
        yazi.enable = lib.mkIf cfg.filemanager.yazi (lib.mkDefault true);
      };

      services = {
        multimedia.audio.enable = lib.mkIf cfg.audio.enable (lib.mkDefault true);
        hardware.printing.enable = lib.mkIf cfg.printing.enable (lib.mkDefault true);
      };
    };
  };
}

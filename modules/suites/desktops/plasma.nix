{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.plasma;
in
{
  options.myFeatures.suites.desktops.plasma = {
    enable = lib.mkEnableOption "KDE Plasma Desktop Suite";

    filemanager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Dolphin file manager.";
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
      platforms.desktops.kde.enable = true;

      programs.utilities.filemanager = lib.mkIf cfg.filemanager.enable {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "dolphin";
        yazi.enable = lib.mkIf cfg.filemanager.yazi (lib.mkDefault true);
      };

      services = {
        multimedia.audio.enable = lib.mkIf cfg.audio.enable (lib.mkDefault true);
        hardware.printing.enable = lib.mkIf cfg.printing.enable (lib.mkDefault true);
      };
    };
  };
}

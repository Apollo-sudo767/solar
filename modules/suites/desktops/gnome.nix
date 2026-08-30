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
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms.desktops.gnome.enable = true;

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nautilus";
        yazi.enable = lib.mkDefault true;
      };

      services = {
        multimedia.audio.enable = lib.mkDefault true;
        hardware.printing.enable = lib.mkDefault true;
      };
    };
  };
}

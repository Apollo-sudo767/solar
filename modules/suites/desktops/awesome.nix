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

      programs.utilities.filemanager = {
        enable = lib.mkDefault true;
        selection = lib.mkDefault "nautilus";
        yazi.enable = lib.mkDefault true;
      };

      services.multimedia.audio.enable = lib.mkDefault true;
    };
  };
}

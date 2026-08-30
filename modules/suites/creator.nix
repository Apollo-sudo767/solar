{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.creator;
in
{
  options.myFeatures.suites.creator = {
    enable = lib.mkEnableOption "Content Creation & Media Production Suite (DaVinci Resolve, OBS Studio, VLC, Ani-CLI, Media Tools)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.programs.media = {
      davinci.enable = lib.mkDefault true;
      obs.enable = lib.mkDefault true;
      vlc.enable = lib.mkDefault true;
      media.enable = lib.mkDefault true;
      ani-cli.enable = lib.mkDefault true;
    };
  };
}

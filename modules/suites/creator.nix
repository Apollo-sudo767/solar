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

    davinci = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable DaVinci Resolve Studio video editor.";
      };
    };

    obs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable OBS Studio screen recorder and streaming suite.";
      };
    };

    vlc = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable VLC media player.";
      };
    };

    mediaTools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable universal media tools, codecs, and MPV.";
      };
    };

    aniCli = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Ani-CLI anime streaming CLI.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.programs.media = {
      davinci.enable = lib.mkIf cfg.davinci.enable (lib.mkDefault true);
      obs.enable = lib.mkIf cfg.obs.enable (lib.mkDefault true);
      vlc.enable = lib.mkIf cfg.vlc.enable (lib.mkDefault true);
      media.enable = lib.mkIf cfg.mediaTools.enable (lib.mkDefault true);
      ani-cli.enable = lib.mkIf cfg.aniCli.enable (lib.mkDefault true);
    };
  };
}

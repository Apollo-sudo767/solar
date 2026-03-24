{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.media;
in {
  options.myFeatures.programs.media = {
    enable = lib.mkEnableOption "Apollo's Media Suite";
    mpv.enable = lib.mkEnableOption "MPV with 1440p GPU acceleration" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      home.packages = with pkgs; [
        imv
      ];

      programs.mpv = lib.mkIf cfg.mpv.enable {
        enable = true;
        config = {
          hwdec = "auto-safe";
          vo = "gpu";
          profile = "gpu-hq";
          ytdl-format = "bestvideo[height<=?1440]+bestaudio/best";
        };
      };
    });
  };
}

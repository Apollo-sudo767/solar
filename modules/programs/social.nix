{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.programs.social;
in
{
  options.myFeatures.programs.social.enable = lib.mkEnableOption "Spotify and Vesktop";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      home.packages = [ 
        pkgs.spotify 
      ];
      
      programs.vesktop = {
        enable = true;
        settings = {
          discordBranch = "stable";
          hardwareAcceleration = true;
          vencord = {
            settings.plugins = {
              ChatInputButtonAPI.enabled = true;
              MemberCount.enabled = true;
            };
          };
        };
      };
    });
  };
}

{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.programs.social;
in
{
  options.myFeatures.programs.social.enable = lib.mkEnableOption "Spotify and Vesktop";

  config = lib.mkIf cfg.enable {
    home-manager.users.apollo = {
      home.packages = [ 
        pkgs.spotify 
      ];
      
      # Vesktop (Discord with Vencord built-in)
      programs.vesktop = {
        enable = true;
        settings = {
          discordBranch = "stable";
          hardwareAcceleration = true; # Uses that 4070 Ti
          vencord = {
            settings.plugins = {
              ChatInputButtonAPI.enabled = true;
              MemberCount.enabled = true;
            };
          };
        };
      };
    };
  };
}

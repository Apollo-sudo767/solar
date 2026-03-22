{ config, lib, pkgs, ... }:
{
  options.myFeatures.programs.media.social.enable = lib.mkEnableOption "Spotify and Vesktop";

  config = lib.mkIf config.myFeatures.programs.media.social.enable {
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

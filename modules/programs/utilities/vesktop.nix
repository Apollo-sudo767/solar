{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.vesktop;

  isDE =
    (config.myFeatures.platforms.desktops.kde.enable or false)
    || (config.myFeatures.platforms.desktops.gnome.enable or false)
    || (config.myFeatures.platforms.desktops.cosmic.enable or false);
in
{
  options.myFeatures.programs.utilities.vesktop = {
    enable = lib.mkEnableOption "Vesktop";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.vesktop = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        settings = {
          discordBranch = "stable";
          hardwareAcceleration = true;
          useNativeTitlebar = lib.mkDefault isDE;
          vencord = {
            settings.plugins = {
              ChatInputButtonAPI.enabled = true;
              MemberCount.enabled = true;
            };
          };
        };
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/vesktop"
              ".config/Vencord"
              ".config/discord"
            ];
          });
        };
  };
}

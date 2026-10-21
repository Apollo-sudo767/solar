# modules/programs/media/davinci.nix
#
# Installs DaVinci Resolve non-linear video editor and preserves user project data.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myFeatures.programs.media.davinci;
in
{
  options.myFeatures.programs.media.davinci.enable = lib.mkEnableOption "Enable Davinci-resolve";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = [
        pkgs.davinci-resolve
      ];

    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/DaVinciResolve"
              ".config/DaVinciResolve"
            ];
          });
        };
  };
}

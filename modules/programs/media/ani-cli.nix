{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.ani-cli;
in
{
  options.myFeatures.programs.media.ani-cli.enable = lib.mkEnableOption "ani-cli CLI anime player";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = [
        pkgs.ani-cli
      ];
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/state/ani-cli"
              ".cache/ani-cli"
            ];
          });
        };
  };
}

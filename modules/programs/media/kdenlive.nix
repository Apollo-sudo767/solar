{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.kdenlive;
in
{
  options.myFeatures.programs.media.kdenlive.enable = lib.mkEnableOption "Kdenlive Video Editor";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = with pkgs; [
        kdePackages.kdenlive
      ];
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/kdenlive"
              ".config/kdenlive"
            ];
            files = [
              ".config/kdenliverc"
            ];
          });
        };
  };
}

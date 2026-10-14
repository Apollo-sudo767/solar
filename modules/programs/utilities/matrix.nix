{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.matrix;
in
{
  options.myFeatures.programs.utilities.matrix = {
    enable = lib.mkEnableOption "Element-Desktop Matrix client";

    package = lib.mkPackageOption pkgs "element-desktop" { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = [
        cfg.package
      ];
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/Element"
            ];
          });
        };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.prism;
in
{
  options.myFeatures.programs.media.prism = {
    enable = lib.mkEnableOption "Prism Launcher";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      # This overrides Prism's internal wrapper to expose all necessary JDKs
      (pkgs.prismlauncher.override {
        jdks = with pkgs; [
          temurin-bin-21 # For modern Minecraft (1.20.5+)
          temurin-bin-17 # For intermediate versions (1.17 - 1.20.4)
          openjdk8 # For legacy and classic modpacks (1.16.5 and below)
        ];
      })
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
            directories = [
              ".local/share/PrismLauncher"
            ];
          });
        };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.minecraft.java;
  prismCfg = config.myFeatures.programs.media.prism;
  enabled = cfg.enable || (prismCfg.enable or false);
in
{
  options.myFeatures.programs.media.minecraft.java = {
    enable = lib.mkEnableOption "Minecraft: Java Edition (Prism Launcher with Java 8/17/21/25)";
  };

  # Backwards compatibility alias
  options.myFeatures.programs.media.prism = {
    enable = lib.mkEnableOption "Prism Launcher (alias for minecraft.java)";
  };

  config = lib.mkIf enabled {
    environment.systemPackages = [
      (pkgs.prismlauncher.override {
        additionalLibs = with pkgs; [
          libxi
          libxtst
          libxfixes
          libxkbcommon
        ];
        jdks = with pkgs; [
          temurin-bin-25 # Modern Minecraft (1.26+)
          temurin-bin-21 # Modern Minecraft (1.20.5+)
          temurin-bin-17 # Intermediate versions (1.17 - 1.20.4)
          openjdk8 # Legacy and classic modpacks (1.16.5 and below)
        ];
      })
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/PrismLauncher"
              ".config/PrismLauncher"
            ];
          });
        };
  };
}

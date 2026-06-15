{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.gaming;
in
{
  options.myFeatures.programs.media.gaming = {
    enable = lib.mkEnableOption "Gaming Suite";
    prism.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Prism Launcher with complete Java toolchain (Java 8, 17, and 21)";
    };
    steam.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Steam and gaming performance tools";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Prism Launcher Module
      (lib.mkIf cfg.prism.enable {
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
              directories = lib.concatMap (name: [
                "/home/${name}/.local/share/PrismLauncher"
              ]) config.myFeatures.core.system.users.usernames;
            };
      })

      # Steam Module
      (lib.mkIf cfg.steam.enable {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true; # Useful if you host local test servers
        };

        environment.systemPackages = with pkgs; [
          mangohud
          gamemode
          libkrb5
          keyutils
        ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = lib.concatMap (name: [
                "/home/${name}/.local/share/Steam"
              ]) config.myFeatures.core.system.users.usernames;
            };

        # Declarative Bulk Storage for Steam
        # This maps ~/.local/share/SteamBulk to the cold storage pool (HDD/SATA SSD)
        preservation.preserveAt."${config.myFeatures.core.system.preservation.coldPath}" =
          lib.mkIf (config.myFeatures.core.system.preservation.enable && (config.myFeatures.core.system.preservation.coldPath != config.myFeatures.core.system.preservation.persistentPath))
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
                directories = [
                  {
                    directory = ".local/share/SteamBulk";
                    mode = "0700";
                  }
                ];
              });
            };

        # Ensure the directory exists with correct ownership on the bulk drive
        systemd.tmpfiles.rules = lib.concatMap (name: [
          "d /home/${name}/.local/share/SteamBulk 0700 ${name} users - -"
        ]) config.myFeatures.core.system.users.usernames;
      })
    ]
  );
}

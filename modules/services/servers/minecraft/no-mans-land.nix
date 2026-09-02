{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.no-mans-land;
  iconFile = ../../../../assets/icons/no-mans-land.png;

  modpack = pkgs.fetchModrinthModpack {
    url = "https://github.com/Phas-MC/NoMansLand/releases/download/Alpha2/PhasMC.s.No.Man.s.Land.mrpack";
    packHash = "sha256-pfVWRbMMck7aovjOlU+A2JhU0haNTys2GfcmO+K/p/E=";
    side = "server";
  };
in
{
  imports = lib.optional (!isDarwin) inputs.nix-minecraft.nixosModules.minecraft-servers;

  options.myFeatures.services.servers.minecraft.no-mans-land = {
    enable = lib.mkEnableOption "PhasMC No Man's Land Minecraft 1.21.1 NeoForge Modpack Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
      description = "The port for the Minecraft server.";
    };
    voicePort = lib.mkOption {
      type = lib.types.port;
      default = 24454;
      description = "The UDP port for Simple Voice Chat communication.";
    };
    motd = lib.mkOption {
      type = lib.types.str;
      default = "PhasMC No Man's Land 1.21.1";
      description = "Message of the day displayed in the server list.";
    };
    jvmOpts = lib.mkOption {
      type = lib.types.str;
      default = "-Xmx12G -Xms12G -XX:+UseZGC -XX:+ZGenerational -XX:+UnlockExperimentalVMOptions -Dneoforge.forceignoreConfigMismatch=true -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem";
      description = "JVM execution flags and memory allocation.";
    };
    autoBackup = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable automated BorgBackup snapshots for the server world data.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

        services.minecraft-servers = {
          enable = true;
          eula = true;

          servers.no-mans-land = {
            enable = true;
            package = pkgs.minecraftServers.neoforge-1_21_1;

            inherit (cfg) jvmOpts;

            symlinks = {
              "mods" = "${modpack}/mods";
            };

            files = {
              "server-icon.png" = iconFile;
              "config" = "${modpack}/pack-src/overrides/config";
              "defaultconfigs" = "${modpack}/pack-src/overrides/defaultconfigs";
              ".sable" = "${modpack}/pack-src/overrides/.sable";
              ".mixin.out" = "${modpack}/pack-src/overrides/.mixin.out";
              "data" = "${modpack}/pack-src/overrides/data";

              # Disable Sable UDP pipeline to prevent client-side NullPointerException on join
              "config/sable-common.toml" = pkgs.writeText "sable-common.toml" ''
                sub_level_splitting = true
                sub_level_splitting_heatmap_steps = 200
                sub_level_tracking_range = 320.0
                sub_levels_with_players_cannot_unload = true
                sub_level_remove_min = -10000.0
                sub_level_remove_max = 100000.0
                sub_level_velocity_retained_on_load = 0.9
                sub_level_punch_strength_multiplier = 2.1
                sub_level_punch_downward_strength_multiplier = 0.175
                sub_level_punch_cooldown_ticks = 3
                disable_udp_pipeline = true
                attempt_udp_networking = false
                sub_level_saving_log_message = true
                verbose_serialization_logging = false
              '';

              # Simple Voice Chat port override if modified from default 24454
              "config/voicechat/voicechat-server.properties" = lib.mkIf (cfg.voicePort != 24454) (
                pkgs.writeText "voicechat-server.properties" ''
                  port=${toString cfg.voicePort}
                  max_voice_distance=48.0
                  whisper_distance=24.0
                  codec=VOIP
                  mtu_size=1275
                  tcp_rate_limit=16
                  keep_alive=1000
                  enable_groups=true
                  allow_recording=true
                  allow_pings=true
                  use_natives=true
                ''
              );
            };

            serverProperties = {
              server-port = cfg.port;
              online-mode = true;
              enforce-secure-profile = false;
              inherit (cfg) motd;
              allow-flight = true;
            };
          };
        };

        systemd.services.minecraft-server-no-mans-land = {
          unitConfig.StartLimitIntervalSec = lib.mkForce 0;
          serviceConfig = {
            Restart = "always";
            RestartSec = "10s";
            TimeoutStopSec = lib.mkForce "120s";
          };
        };

        networking.firewall.allowedTCPPorts = [ cfg.port ];
        networking.firewall.allowedUDPPorts = [
          cfg.port
          cfg.voicePort
        ];

        services.borgbackup.jobs.minecraft-no-mans-land = lib.mkIf cfg.autoBackup {
          paths = [ "/srv/minecraft/no-mans-land" ];
          repo = "/mnt/backups/minecraft/no-mans-land";
          encryption.mode = "none";
          compression = "auto,zstd";
          startAt = "0/4:00:00";
          prune.keep = {
            within = "1d"; # Keep all 4-hourly backups for the last 24h
            daily = 7;
            weekly = 4;
            monthly = 6;
          };
        };
      })
    ]
  );
}

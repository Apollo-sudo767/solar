{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.create-aero;
  iconFile = ../../../../assets/icons/create-aero.png;

  modpack = pkgs.fetchModrinthModpack {
    url = "https://cdn.modrinth.com/data/TnPYNGac/versions/BZwpxcJk/Aeronautics-%20Cogs%20%26%20Clouds.mrpack";
    packHash = "sha256-6JRYxzCwJcUAAZJ4f9Bt+217QCZE/e3emD0zkXGSk7A=";
    side = "server";
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.servers.minecraft.create-aero = {
    enable = lib.mkEnableOption "Create Aeronautics Minecraft 1.21.1 Neoforge Modpack";
    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers.create-aero = {
        enable = true;
        package = pkgs.minecraftServers.neoforge-1_21_1;
        jvmOpts = "-Xmx12G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        files = {
          "server-icon.png" = iconFile;
          "config" = "${modpack}/pack-src/overrides/config";
          # REMOVED: "defaultconfigs" because it does not exist in this modpack
        };

        serverProperties = {
          server-port = cfg.port;
          online-mode = true;
          enforce-secure-profile = false;
          motd = "PhasMC Create Aero 1.21.1";
        };
      };
    };

    systemd.services.minecraft-server-create-aero = {
      unitConfig.StartLimitIntervalSec = lib.mkForce 0;
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        TimeoutStopSec = lib.mkForce "120s";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    services.borgbackup.jobs.minecraft-create-aero = {
      paths = [ "/srv/minecraft/create-aero" ];
      repo = "/mnt/backups/minecraft/create-aero";
      encryption.mode = "none";
      compression = "auto,zstd";
      startAt = "daily";
    };
  };
}

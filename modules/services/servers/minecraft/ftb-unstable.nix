{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.ftb-unstable;
  iconFile = ../../../../assets/icons/ftb.png;

  modpack = pkgs.fetchzip {
    url = "https://github.com/Apollo-sudo767/solar-modpacks/releases/download/ModPack/ftb-unstable-1.21-structured.zip";
    hash = "sha256-NM885zTCnSjZk33g5ybzM1+m3g/Et2llaB0txqLGVas=";
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.servers.minecraft.ftb-unstable = {
    enable = lib.mkEnableOption "FTB Unstable 1.21 NeoForge Server";
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

      servers.ftb-unstable = {
        enable = true;
        package = pkgs.minecraftServers.neoforge-1_21;
        jvmOpts = "-Xmx8G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        files = {
          "server-icon.png" = iconFile;
          "config" = "${modpack}/config";
          # defaultconfigs and kubejs removed as they are not in the source zip
        };

        serverProperties = {
          server-port = cfg.port;
          online-mode = true;
          enforce-secure-profile = false;
          motd = "Solar | FTB Unstable 1.21";
        };
      };
    };

    systemd.services.minecraft-server-ftb-unstable = {
      unitConfig.StartLimitIntervalSec = lib.mkForce 0;
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        TimeoutStopSec = lib.mkForce "120s";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    services.borgbackup.jobs.minecraft-ftb-unstable = {
      paths = [ "/srv/minecraft/ftb-unstable" ];
      repo = "/mnt/backups/minecraft/ftb-unstable";
      encryption.mode = "none";
      compression = "auto,zstd";
      startAt = "daily";
    };
  };
}

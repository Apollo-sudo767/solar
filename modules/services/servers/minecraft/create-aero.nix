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
    url = "https://cdn.modrinth.com/data/TnPYNGac/versions/jeow6uiA/Aeronautics-%20Cogs%20%26%20Clouds.mrpack?mr_download_reason=standalone";
    packHash = "sha256-+mUy8XuOQttBcEGifGFfBNIIPvyt+C/0klE2BcYUyQM=";
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
    mapPort = lib.mkOption {
      type = lib.types.port;
      default = 8100;
      description = "The port for the BlueMap web interface.";
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
        # Updated to Generational ZGC for better physics entity performance and consistent 12GB heap
        jvmOpts = "-Xmx12G -Xms12G -XX:+UseZGC -XX:+ZGenerational -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem";

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        files = {
          "server-icon.png" = iconFile;
          "config" = "${modpack}/pack-src/overrides/config";

          "config/bluemap/core.conf" = pkgs.writeText "bluemap-core.conf" ''
            accept-download: true
            render-thread-count: 2
          '';

          "config/bluemap/webserver.conf" = pkgs.writeText "bluemap-webserver.conf" ''
            enabled: true
            webroot: "bluemap/web"
            port: ${toString cfg.mapPort}
            ip: "0.0.0.0"
          '';

          # Explicit Map Definitions to fix the "New World" loading error
          "config/bluemap/maps/overworld.conf" = pkgs.writeText "overworld.conf" ''
            name: "Overworld"
            world: "../../world"
            sorting: 0
          '';

          "config/bluemap/maps/nether.conf" = pkgs.writeText "nether.conf" ''
            name: "Nether"
            world: "../../world/DIM-1"
            sorting: 10
          '';

          "config/bluemap/maps/end.conf" = pkgs.writeText "end.conf" ''
            name: "The End"
            world: "../../world/DIM1"
            sorting: 20
          '';
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

    networking.firewall.allowedTCPPorts = [
      cfg.port
      cfg.mapPort
    ];
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

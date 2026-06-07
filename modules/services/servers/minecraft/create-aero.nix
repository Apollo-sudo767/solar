{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.create-aero;
  iconFile = ../../../../assets/icons/create-aero.png;

  modpack = pkgs.fetchModrinthModpack {
    url = "https://cdn.modrinth.com/data/TnPYNGac/versions/u5q41yug/Aeronautics-%20Cogs%20%26%20Clouds.mrpack?mr_download_reason=standalone";
    packHash = "sha256-MGgXheCMgPQk2k0FvJBq4CQ/p9oyeO0CEI2GY/WWJ4M=";
    side = "server";
  };
in
{
  imports = lib.optional (!isDarwin) inputs.nix-minecraft.nixosModules.minecraft-servers;

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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

        services.minecraft-servers = {
          enable = true;
          eula = true;

          servers.create-aero = {
            enable = true;
            package = pkgs.minecraftServers.neoforge-1_21_1;

            jvmOpts = "-Xmx12G -Xms12G -XX:+UseZGC -XX:+ZGenerational -XX:+UnlockExperimentalVMOptions -Dneoforge.forceignoreConfigMismatch=true -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem";

            symlinks = {
              "mods" = "${modpack}/mods";
            };

            files = {
              "server-icon.png" = iconFile;
              "config" = "${modpack}/pack-src/overrides/config";

              # ACCEPT DOWNLOADS
              "config/bluemap/core.conf" = pkgs.writeText "bluemap-core.conf" ''
                accept-download: true
                render-thread-count: 2
              '';

              # FIX WEBSERVER PATH
              "config/bluemap/webserver.conf" = pkgs.writeText "bluemap-webserver.conf" ''
                enabled: true
                webroot: "bluemap/web"
                port: ${toString cfg.mapPort}
                ip: "0.0.0.0"
              '';

              # USE ABSOLUTE PATHS FOR ALL DIMENSIONS
              "config/bluemap/maps/overworld.conf" = pkgs.writeText "overworld.conf" ''
                name: "Overworld"
                world: "/srv/minecraft/create-aero/world"
                sorting: 0
              '';

              "config/bluemap/maps/aether.conf" = pkgs.writeText "aether.conf" ''
                name: "The Aether"
                world: "/srv/minecraft/create-aero/world/dimensions/aether/the_aether"
                sorting: 5
              '';

              "config/bluemap/maps/nether.conf" = pkgs.writeText "nether.conf" ''
                name: "Nether"
                world: "/srv/minecraft/create-aero/world/DIM-1"
                sorting: 10
              '';

              "config/bluemap/maps/end.conf" = pkgs.writeText "end.conf" ''
                name: "The End"
                world: "/srv/minecraft/create-aero/world/DIM1"
                sorting: 20
              '';
            };

            serverProperties = {
              server-port = cfg.port;
              online-mode = true;
              enforce-secure-profile = false;
              motd = "PhasMC Create Aero 1.21.1";
              allow-flight = true;
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
          exclude = [ "/srv/minecraft/create-aero/bluemap" ];
          repo = "/mnt/backups/minecraft/create-aero";
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

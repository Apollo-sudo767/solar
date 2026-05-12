{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.create-aero;
  serverPath = "/srv/minecraft/create-aero";
  worldPath = "${serverPath}/world";
  # We move the configs to a dedicated folder to stop Nix/BlueMap permission wars
  externalConfigDir = "${serverPath}/bluemap-configs";
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
    enable = lib.mkEnableOption "Create Aeronautics Minecraft 1.21.1";
    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
    };
    mapPort = lib.mkOption {
      type = lib.types.port;
      default = 8100;
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
        jvmOpts = "-Xmx12G -Xms12G -XX:+UseZGC -XX:+ZGenerational -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem";

        symlinks = {
          "mods" = "${modpack}/mods";
          # Direct BlueMap to look at our externally managed config folder
          "config/bluemap" = externalConfigDir;
        };

        files = {
          "server-icon.png" = iconFile;
          "config" = "${modpack}/pack-src/overrides/config";
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
        # DISCOVERY SCRIPT RUNS AS ROOT
        ExecStartPre = lib.mkBefore [
          (pkgs.writeShellScript "bluemap-discovery" ''
                        set -eu
                        # Ensure paths exist
                        mkdir -p "${externalConfigDir}/maps"
                        
                        # Write core config
                        cat <<EOF > "${externalConfigDir}/core.conf"
            accept-download: true
            render-thread-count: 2
            data: "bluemap"
            EOF

                        # Write webserver config
                        cat <<EOF > "${externalConfigDir}/webserver.conf"
            enabled: true
            webroot: "bluemap/web"
            port: ${toString cfg.mapPort}
            ip: "0.0.0.0"
            EOF

                        # Auto-discover dimensions
                        if [ -d "${worldPath}" ]; then
                          find "${worldPath}" -name "level.dat" | while read -r levelPath; do
                            dimPath=$(dirname "$levelPath")
                            id=$(echo "$dimPath" | sed 's|${worldPath}||' | sed 's|^/||' | tr '/' '-' || echo "overworld")
                            [ -z "$id" ] && id="overworld"
                            name=$(basename "$dimPath" | sed 's/_/ /g' | sed -e 's/\b\(.\)/\u\1/g')
                            [ "$id" = "overworld" ] && name="Overworld"
                            
                            cat <<MAP > "${externalConfigDir}/maps/$id.conf"
            name: "$name"
            world: "$dimPath"
            sorting: 10
            MAP
                          done
                        fi

                        # Clean up permissions
                        chown -R minecraft:minecraft "${externalConfigDir}"
                        chown -R minecraft:minecraft "${serverPath}"
          '')
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${serverPath}/saves 0770 minecraft minecraft -"
      "d ${externalConfigDir} 0770 minecraft minecraft -"
    ];

    networking.firewall.allowedTCPPorts = [
      cfg.port
      cfg.mapPort
    ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    services.borgbackup.jobs.minecraft-create-aero = {
      paths = [ serverPath ];
      repo = "/mnt/backups/minecraft/create-aero";
      encryption.mode = "none";
      compression = "auto,zstd";
      startAt = "daily";
    };
  };
}

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.texkit;
  iconFile = ../../../../assets/icons/texkit.png;

  modpack = pkgs.fetchzip {
    url = "https://tekxit.lol/downloads/tekxit4/16.8.4Tekxit4Server.zip";
    hash = "sha256-pzDFm5uejOKDDoEWbhQ3vdpV/WFlDpODi5j4gdkhIG4=";
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.servers.minecraft.texkit = {
    enable = lib.mkEnableOption "Texkit 4 Fabric Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.haveged.enable = true; # Entropy for faster startup

    services.minecraft-servers = {
      enable = true;
      eula = true;

      managementSystem = {
        tmux.enable = lib.mkForce false;
        systemd-socket.enable = true;
      };

      servers.texkit = {
        enable = true;
        package = pkgs.minecraftServers.fabric-1_19_2;

        # Solar Performance Tuning: Forge BMC4 needs ~10GB minimum
        jvmOpts = "-Xmx2G -Xms6G -XX:+UseG1GC";

        symlinks = {
          "mods" = "${modpack}/mods";
          "config" = "${modpack}/config";
          "defaultconfigs" = "${modpack}/defaultconfigs";
          "kubejs" = "${modpack}/kubejs";
        };

        files = {
          "server-icon.png" = iconFile;
        };

        serverProperties = {
          server-port = cfg.port;
          online-mode = true;
          enforce-secure-profile = false;
          max-players = 10;
          motd = "Solar | Texkit 4";
        };
      };
    };

    # Systemd reliability overrides
    systemd.services.minecraft-server-better-mc = {
      unitConfig.StartLimitIntervalSec = lib.mkForce 0;
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        StandardOutput = "journal";
        StandardError = "journal";
        TimeoutStopSec = lib.mkForce "120s";
      };
    };

    services.borgbackup.jobs.minecraft-texkit = {
      paths = [ "/srv/minecraft/texkit" ];
      repo = "/mnt/backups/minecraft/texkit";
      encryption = {
        mode = "none";
      };
      compression = "auto,zstd"; # High compression, great for Tectonic world files
      startAt = "daily";
    };

    # Firewall integration
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}

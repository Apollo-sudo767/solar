{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.hexxit;
  iconFile = ../../../../assets/icons/hexxit.png;

  modpack = pkgs.fetchzip {
    url = "https://raw.githubusercontent.com/Apollo-sudo767/solar-modpacks/main/hexxit-revived/pack.toml";
    hash = "sha256-pzDFm5uejOKDDoEWbhQ3vdpV/WFlDpODi5j4gdkhIG4=";
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.servers.minecraft.hexxit = {
    enable = lib.mkEnableOption "hexxit 4 Fabric Server";
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

      servers.hexxit = {
        enable = true;
        package = pkgs.minecraftServers.neoforge-1_20_1;

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
          motd = "Solar | hexxit 4";
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

    services.borgbackup.jobs.minecraft-hexxit = {
      paths = [ "/srv/minecraft/hexxit" ];
      repo = "/mnt/backups/minecraft/hexxit";
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

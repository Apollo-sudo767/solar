{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.vanilla;

  # Utility to fetch mods from Modrinth (Aligned with sllv.nix)
  fetchMod =
    {
      name,
      url,
      hash,
    }:
    pkgs.fetchurl {
      inherit url;
      sha256 = hash;
      name = "${name}.jar";
    };

  # 1.21.1 Verified Mods
  mods = {
    lithium = fetchMod {
      name = "lithium";
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/XQJtuOTA/lithium-fabric-0.15.3%2Bmc1.21.1.jar";
      hash = "sha256-oes7FQtVmwwJdvYo/9X3kUWLmIkWNCEbJyf/eFfRV7g=";
    };
    terralith = fetchMod {
      name = "terralith";
      url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/MuJMtPGQ/Terralith_1.21.x_v2.5.8.jar";
      hash = "sha256-ADM6EwrDi3ucqTcACY1eAuBhK9wtNSKq2i825WAGIb8=";
    };
    tectonic = fetchMod {
      name = "tectonic";
      url = "https://cdn.modrinth.com/data/lWDHr9jE/versions/cXSQRWNy/tectonic-3.0.22-fabric-21.1.jar";
      hash = "sha256-Py0nZWSZaNlMH7xpU+TJMDMDPV7Ch/BRqEswm8f5uqY=";
    };
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.servers.minecraft.vanilla = {
    enable = lib.mkEnableOption "Minecraft Vanilla+ (1.21.1)";
    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.haveged.enable = true; # Entropy for faster server start

    services.minecraft-servers = {
      enable = true;
      eula = true;

      managementSystem = {
        tmux.enable = lib.mkForce false;
        systemd-socket.enable = true;
      };

      servers.vanilla-plus = {
        enable = true;
        package = pkgs.minecraftServers.fabric-1_21_1;

        # Consistent JVM options for 1.21.1 performance
        jvmOpts = "-Xmx6G -Xms6G -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true";

        # Symlinks management matching sllv.nix
        symlinks = lib.mapAttrs' (name: value: lib.nameValuePair "mods/${name}.jar" value) mods;

        serverProperties = {
          server-port = cfg.port;
          online-mode = true;
          enforce-secure-profile = false;
          max-players = 10;
          motd = "Solar Vanilla+ | 1.21.1 Terralith";
        };
      };
    };

    # Systemd stability (identical to sllv.nix logic)
    systemd.services.minecraft-server-vanilla-plus = {
      unitConfig.StartLimitIntervalSec = lib.mkForce 0;
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        TimeoutStopSec = lib.mkForce "120s";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}

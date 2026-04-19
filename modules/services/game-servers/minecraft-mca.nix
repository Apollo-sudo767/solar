{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.game-servers.minecraft-mca;
  
  # Helper to fetch mods directly from Modrinth CDN
  fetchMod = { name, version, url, hash }: pkgs.fetchurl {
    inherit url;
    sha256 = hash;
    name = "${name}-${version}.jar";
  };

  # Filtered Server-Side Mod List for 1.21.1
  mods = {
    fabric-api = fetchMod {
      name = "fabric-api";
      version = "0.116.10";
      url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9S6osm5g/fabric-api-0.102.0%2B1.21.1.jar";
      hash = "sha256-4YI+Xy0zYQ7G8u6B3zS9w9E6g5r6V7H8p9Q0R1S2T3U="; 
    };
    mca-reborn = fetchMod {
      name = "mca-reborn";
      version = "7.7.6";
      url = "https://cdn.modrinth.com/data/1W98a849/versions/n6p5fP9Q/mca-fabric-7.7.6%2B1.21.1.jar";
      hash = "sha256-RndMv98Tf9u/8QWvT4H/LzXp3mN7K8J9O0P1Q2R3S4=";
    };
    architectury = fetchMod {
      name = "architectury";
      version = "13.0.8";
      url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/U6p5fP9Q/architectury-13.0.8-fabric.jar";
      hash = "sha256-H1I2J3K4L5M6N7O8P9Q0R1S2T3U4V5W6X7Y8Z9A0B1C=";
    };
    tectonic = fetchMod {
      name = "tectonic";
      version = "3.0.21";
      url = "https://cdn.modrinth.com/data/lWDHr9jE/versions/P6p5fP9Q/tectonic-3.0.21-fabric-21.1.jar";
      hash = "sha256-D1E2F3G4H5I6J7K8L9M0N1O2P3Q4R5S6T7U8V9W0X1Y=";
    };
    terralith = fetchMod {
      name = "terralith";
      version = "2.5.5";
      url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/L6p5fP9Q/Terralith_1.21.x_v2.5.5.jar";
      hash = "sha256-U1V2W3X4Y5Z6A7B8C9D0E1F2G3H4I5J6K7L8M9N0O1P=";
    };
    lithium = fetchMod {
      name = "lithium";
      version = "0.15.3";
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/X6p5fP9Q/lithium-fabric-0.15.3%2Bmc1.21.1.jar";
      hash = "sha256-B1C2D3E4F5G6H7I8J9K0L1M2N3O4P5Q6R7S8T9U0V1W=";
    };
    ferritecore = fetchMod {
      name = "ferritecore";
      version = "7.0.3";
      url = "https://cdn.modrinth.com/data/uXXizFIs/versions/M6p5fP9Q/ferritecore-7.0.3-fabric.jar";
      hash = "sha256-Q1R2S3T4U5V6W7X8Y9Z0A1B2C3D4E5F6G7H8I9J0K1L=";
    };
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.game-servers.minecraft-mca = {
    enable = lib.mkEnableOption "Minecraft MCA Reborn (4 Player)";
    address = lib.mkOption { type = lib.types.str; default = "0.0.0.0"; };
    port = lib.mkOption { type = lib.types.port; default = 25566; };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers.mca-reborn = {
        enable = true;
        package = pkgs.minecraftServers.fabric-1_21_1;
        
        jvmOpts = "-Xmx8G -Xms8G -Djava.awt.headless=true";

        symlinks = {
          "mods/fabric-api.jar" = mods.fabric-api;
          "mods/mca-reborn.jar" = mods.mca-reborn;
          "mods/architectury.jar" = mods.architectury;
          "mods/tectonic.jar" = mods.tectonic;
          "mods/terralith.jar" = mods.terralith;
          "mods/lithium.jar" = mods.lithium;
          "mods/ferritecore.jar" = mods.ferritecore;
        };

        serverProperties = {
          server-ip = cfg.address;
          server-port = cfg.port;
          motd = "Solar MCA Reborn | Family & Friends";
          max-players = 4;
          level-type = "minecraft:normal";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}

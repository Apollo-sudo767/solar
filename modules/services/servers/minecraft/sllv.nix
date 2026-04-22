{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.servers.minecraft.sllv;

  # Solar Helper: Updated to accept an optional hash, defaulting to lib.fakeHash
  fetchMod = { name, url, hash ? lib.fakeHash }: pkgs.fetchurl {
    inherit url;
    sha256 = hash;
    name = "${name}.jar";
  };

  # Complete server-side mod list
  mods = {
    # --- Core Libraries & APIs ---
    architectury = fetchMod {
      name = "architectury";
      url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/Wto0RchG/architectury-13.0.8-fabric.jar";
      hash = "sha256-EMu7b1+WovGFOwzGhChCTOyJA0CVF7KZ/wI1B1a2OZ0=";
    };
    fabric-api = fetchMod {
      name = "fabric-api";
      url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/IpaMcBLh/fabric-api-0.116.11%2B1.21.1.jar";
      hash = "sha256-t5Heb23OnFjU6ir2xxO7zG3GTQpZlai61vIl7ljPF9I=";
    };
    bad-packets = fetchMod {
      name = "bad-packets";
      url = "https://cdn.modrinth.com/data/ftdbN0KK/versions/hjhT2sMz/badpackets-fabric-0.8.2.jar";
      hash = "sha256-VeoLAcVK1P12mWNkm+sgoZcabIIMmiWKzfQ8o1PZBNg=";
    };
    placeholder-api = fetchMod {
      name = "placeholder-api";
      url = "https://cdn.modrinth.com/data/eXts2L7r/versions/U5bhVym2/placeholder-api-2.4.2%2B1.21.jar";
      hash = "sha256-wBh+4plSesej4LHoNgHc3A3mMeKG/kHmvhp1lY6o5EM=";
    };
    yungs-api = fetchMod {
      name = "yungs-api";
      url = "https://cdn.modrinth.com/data/Ua7DFN59/versions/9aZPNrZC/YungsApi-1.21.1-Fabric-5.1.6.jar";
      hash = "sha256-NvuQOh688VEXRb4tqeUUTx0kZb/3pcF77/00c5ms0bo=";
    };

    # --- Performance ---
    distant-horizons = fetchMod {
      name = "distant-horizons";
      url = "https://cdn.modrinth.com/data/uCdwusMi/versions/VH8Pl4yr/DistantHorizons-3.0.1-b-1.21.1-fabric-neoforge.jar";
      hash = "sha256-B7dlWP7cOUYBiI4AtCdb/ZscaBdtBGx7xdZ4NVfyqmA=";
    };
    lithium = fetchMod {
      name = "lithium";
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/XQJtuOTA/lithium-fabric-0.15.3%2Bmc1.21.1.jar";
      hash = "sha256-oes7FQtVmwwJdvYo/9X3kUWLmIkWNCEbJyf/eFfRV7g=";
    };
    ferritecore = fetchMod {
      name = "ferritecore";
      url = "https://cdn.modrinth.com/data/uXXizFIs/versions/sOzRw3CG/ferritecore-7.0.3-fabric.jar";
      hash = "sha256-mMOrHVqrjxS10ILT8aRncn/TNfAtEkVVyUM5dhxMGPI=";
    };
    lithostitched = fetchMod {
      name = "lithostitched";
      url = "https://cdn.modrinth.com/data/XaDC71GB/versions/Awf91DUj/lithostitched-1.6.8-fabric-21.1.jar";
      hash = "sha256-WL63egOqN8y+n6+sRafoE3zAHNOPuNlO0wgYYOB4cDk=";
    };

    # --- World Generation & Structures ---
    terrablender = fetchMod {
      name = "terrablender";
      url = "https://cdn.modrinth.com/data/kkmrDlKT/versions/XNtIBXyQ/TerraBlender-fabric-1.21.1-4.1.0.8.jar";
      hash = "sha256-+H6Up/oSJ3EcP4rqn/rHoU4Me+IS/lDd7pXSxrpyPKw=";
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
    ctov = fetchMod {
      name = "ctov";
      url = "https://cdn.modrinth.com/data/fgmhI8kH/versions/dqaObRbU/%5BFabric%5Dctov-3.6.3.jar";
      hash = "sha256-5EOSXY/k0JLx85Ji+nMYLknjTcv5ylHqqlMGS7ku5lI=";
    };
    incendium = fetchMod {
      name = "incendium";
      url = "https://cdn.modrinth.com/data/ZVzW5oNS/versions/7mVvV9Th/Incendium_1.21.x_v5.4.4.jar";
      hash = "sha256-KFpPaf4jkfIXX3/JMW1yejnHm90hSSPFkoTVabzmVvQ=";
    };
    nullscape = fetchMod {
      name = "nullscape";
      url = "https://cdn.modrinth.com/data/LPjGiSO4/versions/3fv8O3xX/Nullscape_1.21.x_v1.2.14.jar";
      hash = "sha256-h0nG/dplkzXlARbBjgEs34aZs3iYWcglWa8sb0Jck64=";
    };

    # --- YUNG's Better Series ---
    yungs-caves = fetchMod {
      name = "yungs-caves";
      url = "https://cdn.modrinth.com/data/Dfu00ggU/versions/72UkhXm7/YungsBetterCaves-1.21.1-Fabric-3.1.4.jar";
      hash = "sha256-W6PDLoqiMIPb+f00mX9Q4Dpk4xdWynRcpSV0IeDRN1c=";
    };
    yungs-mineshafts = fetchMod {
      name = "yungs-mineshafts";
      url = "https://cdn.modrinth.com/data/HjmxVlSr/versions/4ybDuGhA/YungsBetterMineshafts-1.21.1-Fabric-5.1.1.jar";
      hash = "sha256-J5SfW64K/v9FdxGltCSCvjAbdryLETbxEg+EhIm7X6Y=";
    };
    yungs-strongholds = fetchMod {
      name = "yungs-strongholds";
      url = "https://cdn.modrinth.com/data/kidLKymU/versions/uYZShp1p/YungsBetterStrongholds-1.21.1-Fabric-5.1.3.jar";
      hash = "sha256-HLQSyDqg6Cc9KaESLFeZ6xWkisyPC3cO/kUcUWZH9fg=";
    };
    yungs-dungeons = fetchMod {
      name = "yungs-dungeons";
      url = "https://cdn.modrinth.com/data/o1C1Dkj5/versions/fQ7EjDPE/YungsBetterDungeons-1.21.1-Fabric-5.1.4.jar";
      hash = "sha256-af59k6+hgD12WN8/hhIT+CVfaNTpdtZt3OZvugjRILw=";
    };
    yungs-desert-temples = fetchMod {
      name = "yungs-desert-temples";
      url = "https://cdn.modrinth.com/data/XNlO7sBv/versions/M6eeDRkC/YungsBetterDesertTemples-1.21.1-Fabric-4.1.5.jar";
      hash = "sha256-K7c+7yeMJ3ZXsn9y0vodkXoXwUBSv1JqK6F19ummMBI=";
    };
    yungs-witch-huts = fetchMod {
      name = "yungs-witch-huts";
      url = "https://cdn.modrinth.com/data/t5FRdP87/versions/bdpPtvTn/YungsBetterWitchHuts-1.21.1-Fabric-4.1.1.jar";
      hash = "sha256-lU/wBN4VFlLZvmngPRuEjW/RWg9fLfFcTOLnZEZ2hec=";
    };
    yungs-ocean-monuments = fetchMod {
      name = "yungs-ocean-monuments";
      url = "https://cdn.modrinth.com/data/3dT9sgt4/versions/TGK6gpeO/YungsBetterOceanMonuments-1.21.1-Fabric-4.1.2.jar";
      hash = "sha256-TPuyJr0dsXAyrH5zBulO0n8aji8+CftixHaI+KUnrew=";
    };
    yungs-nether-fortresses = fetchMod {
      name = "yungs-nether-fortresses";
      url = "https://cdn.modrinth.com/data/Z2mXHnxP/versions/gxBGYcIL/YungsBetterNetherFortresses-1.21.1-Fabric-3.1.5.jar";
      hash = "sha256-d6JY5JlVnxGQyHInf47s8gLdTvBoFnTc6UEAP6Q2f3g=";
    };
    yungs-jungle-temples = fetchMod {
      name = "yungs-jungle-temples";
      url = "https://cdn.modrinth.com/data/z9Ve58Ih/versions/uiGCmR8O/YungsBetterJungleTemples-1.21.1-Fabric-3.1.2.jar";
      hash = "sha256-i2rABDRdqTW1uby3BiT0oxl0EflCDWRZowJST43qQtw=";
    };
    yungs-extras = fetchMod {
      name = "yungs-extras";
      url = "https://cdn.modrinth.com/data/ZYgyPyfq/versions/aVsikHca/YungsExtras-1.21.1-Fabric-5.1.1.jar";
      hash = "sha256-EgAjzJfLXrhpcqd4MlDLs1UF1C1dazHacJBshcD/t/U=";
    };
    yungs-bridges = fetchMod {
      name = "yungs-bridges";
      url = "https://cdn.modrinth.com/data/Ht4BfYp6/versions/8h9N9fvs/YungsBridges-1.21.1-Fabric-5.1.1.jar";
      hash = "sha256-N8wSCs62Jjr7ztru4cn+l3DH1dq9k40AKTAX54EFG0U=";
    };

    # --- Gameplay ---
    mca-reborn = fetchMod {
      name = "mca-reborn";
      url = "https://cdn.modrinth.com/data/1W98a849/versions/1PlgQkBW/mca-fabric-7.7.7%2B1.21.1.jar";
      hash = "sha256-Dhgm6jMrswg4JKrT9GvXNThAJwJQlMAO7qmNaNLW0/M=";
    };
    farmers-delight = fetchMod {
      name = "farmers-delight";
      url = "https://cdn.modrinth.com/data/7vxePowz/versions/YEHRH8LC/FarmersDelight-1.21.1-3.2.8%2Brefabricated.jar";
      hash = "sha256-96/hH+2BVWRvpDCemWlPv6tB4Z2niEtiYqsRLFweLaM=";
    };
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.servers.minecraft.sllv = {
    enable = lib.mkEnableOption "Minecraft MCA Fabric Server (1.21.1)";
    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.haveged.enable = true;

    services.minecraft-servers = {
      enable = true;
      eula = true;

      # Force systemd management instead of tmux to ensure logs hit the journal
      managementSystem.tmux.enable = lib.mkForce false;

      servers.sllv = {
        enable = true;
        package = pkgs.minecraftServers.fabric-1_21_1;

        # Resource-heavy world generation requires ample RAM and specific GC flags
        jvmOpts = lib.concatStringsSep " " [
          "-Xmx8G"
          "-Xms8G"
          "-Djava.net.preferIPv4Stack=true"
          "-Djava.awt.headless=true"
          "-XX:+UseG1GC"
          "-XX:+ParallelRefProcEnabled"
          "-XX:MaxGCPauseMillis=200"
          "-XX:+UnlockExperimentalVMOptions"
          "-XX:+DisableExplicitGC"
          "-XX:+AlwaysPreTouch"
          "-XX:G1NewSizePercent=30"
          "-XX:G1MaxNewSizePercent=40"
          "-XX:G1HeapRegionSize=8M"
          "-XX:G1ReservePercent=20"
          "-XX:G1HeapWastePercent=5"
          "-XX:G1MixedGCCountTarget=4"
          "-XX:InitiatingHeapOccupancyPercent=15"
          "-XX:G1MixedGCLiveThresholdPercent=90"
          "-XX:G1RSetUpdatingPauseTimePercent=5"
          "-XX:SurviorRatio=32"
          "-XX:+PerfDisableSharedMem"
          "-XX:MaxTenuringThreshold=1"
        ];

        symlinks = lib.mapAttrs' (name: value: lib.nameValuePair "mods/${name}.jar" value) mods;

        serverProperties = {
          server-port = cfg.port;
          online-mode = true;
          enforce-secure-profile = false;
          max-players = 4;
          gamemode = "survival";
          motd = "Solar MCA Server | 1.21.1 Fabric";
          simulation-distance = 8;
          view-distance = 10;
        };
      };
    };

    systemd.services.minecraft-server-sllv = {
      unitConfig = {
        StartLimitIntervalSec = 0; # Allow infinite retries while we debug mod loads
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}

{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.game-servers.minecraft-mca;
  
  fetchMod = { name, url, hash ? lib.fakeHash }: pkgs.fetchurl {
    inherit url;
    sha256 = hash;
    name = "${name}.jar";
  };
  mods = {
    # Core Libraries & APIs - Updated Version IDs
    fabric-api = fetchMod { name = "fabric-api"; url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/v2W8Z9O2/fabric-api-0.102.1%2B1.21.1.jar"; };
    architectury = fetchMod { name = "architectury"; url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/lhGA9TYQ/architectury-13.0.6-fabric.jar"; };
    cloth-config = fetchMod { name = "cloth-config"; url = "https://cdn.modrinth.com/data/9s6osm5g/versions/9s6osm5g/cloth-config-15.0.140-fabric.jar"; };
    bad-packets = fetchMod { name = "bad-packets"; url = "https://cdn.modrinth.com/data/ftdbN0KK/versions/ftdbN0KK/badpackets-fabric-0.8.2.jar"; };
    geckolib = fetchMod { name = "geckolib"; url = "https://cdn.modrinth.com/data/8BmcQJ2H/versions/8BmcQJ2H/geckolib-fabric-1.21.1-4.8.4.jar"; };
    placeholder-api = fetchMod { name = "placeholder-api"; url = "https://cdn.modrinth.com/data/eXts2L7r/versions/eXts2L7r/placeholder-api-2.4.2+1.21.jar"; };

    # Performance
    lithium = fetchMod { name = "lithium"; url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/gvQqBUqZ/lithium-fabric-0.15.3%2Bmc1.21.1.jar"; };
    ferritecore = fetchMod { name = "ferritecore"; url = "https://cdn.modrinth.com/data/uXXizFIs/versions/uXXizFIs/ferritecore-7.0.3-fabric.jar"; };

    # Gameplay & Content
    farmers-delight = fetchMod { name = "farmers-delight"; url = "https://cdn.modrinth.com/data/7vxePowz/versions/7vxePowz/FarmersDelight-1.21.1-3.2.8%2Brefabricated.jar"; };
    mca-reborn = fetchMod { name = "mca-reborn"; url = "https://cdn.modrinth.com/data/1W98a849/versions/1W98a849/mca-fabric-7.7.6+1.21.1.jar"; };

    # World Generation
    ctov = fetchMod { name = "ctov"; url = "https://cdn.modrinth.com/data/fgmhI8kH/versions/fgmhI8kH/%5BFabric%5Dctov-3.6.3.jar"; };
    tectonic = fetchMod { name = "tectonic"; url = "https://cdn.modrinth.com/data/lWDHr9jE/versions/lWDHr9jE/tectonic-3.0.21-fabric-21.1.jar"; };
    terralith = fetchMod { name = "terralith"; url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/8oi3bsk5/Terralith_1.21.x_v2.5.8.jar"; };
    terrablender = fetchMod { name = "terrablender"; url = "https://cdn.modrinth.com/data/kkmrDlKT/versions/kkmrDlKT/TerraBlender-fabric-1.21.1-4.1.0.8.jar"; };
    lithostitched = fetchMod { name = "lithostitched"; url = "https://cdn.modrinth.com/data/XaDC71GB/versions/XaDC71GB/lithostitched-1.6.3-fabric-21.1.jar"; };

    # Distant Horizons (Verified Hash from previous run)
    distant-horizons = fetchMod { 
      name = "distant-horizons"; 
      url = "https://cdn.modrinth.com/data/uCdwusMi/versions/VH8Pl4yr/DistantHorizons-3.0.1-b-1.21.1-fabric-neoforge.jar"; 
      hash = "sha256-B7dlWP7cOUYBiI4AtCdb/ZscaBdtBGx7xdZ4NVfyqmA=";
    };

    # YUNG's Suite - FIXED 404s
    yungs-api = fetchMod { name = "yungs-api"; url = "https://cdn.modrinth.com/data/Ua7DFN59/versions/Ua7DFN59/YungsApi-1.21.1-Fabric-5.1.6.jar"; };
    yungs-caves = fetchMod { name = "yungs-caves"; url = "https://cdn.modrinth.com/data/Dfu00ggU/versions/Dfu00ggU/YungsBetterCaves-1.21.1-Fabric-3.1.4.jar"; };
    yungs-desert-temples = fetchMod { name = "yungs-desert-temples"; url = "https://cdn.modrinth.com/data/XNlO7sBv/versions/XNlO7sBv/YungsBetterDesertTemples-1.21.1-Fabric-4.1.5.jar"; };
    yungs-dungeons = fetchMod { name = "yungs-dungeons"; url = "https://cdn.modrinth.com/data/o1C1Dkj5/versions/o1C1Dkj5/YungsBetterDungeons-1.21.1-Fabric-5.1.4.jar"; }; # Fixed ID
    yungs-jungle-temples = fetchMod { name = "yungs-jungle-temples"; url = "https://cdn.modrinth.com/data/z9Ve58Ih/versions/z9Ve58Ih/YungsBetterJungleTemples-1.21.1-Fabric-3.1.2.jar"; };
    yungs-mineshafts = fetchMod { name = "yungs-mineshafts"; url = "https://cdn.modrinth.com/data/HjmxVlSr/versions/HjmxVlSr/YungsBetterMineshafts-1.21.1-Fabric-5.1.1.jar"; };
    yungs-nether-fortresses = fetchMod { name = "yungs-nether-fortresses"; url = "https://cdn.modrinth.com/data/Z2mXHnxP/versions/Z2mXHnxP/YungsBetterNetherFortresses-1.21.1-Fabric-3.1.5.jar"; };
    yungs-ocean-monuments = fetchMod { name = "yungs-ocean-monuments"; url = "https://cdn.modrinth.com/data/3dT9sgt4/versions/3dT9sgt4/YungsBetterOceanMonuments-1.21.1-Fabric-4.1.2.jar"; };
    yungs-strongholds = fetchMod { name = "yungs-strongholds"; url = "https://cdn.modrinth.com/data/kidLKymU/versions/kidLKymU/YungsBetterStrongholds-1.21.1-Fabric-5.1.3.jar"; };
    yungs-witch-huts = fetchMod { name = "yungs-witch-huts"; url = "https://cdn.modrinth.com/data/t5FRdP87/versions/t5FRdP87/YungsBetterWitchHuts-1.21.1-Fabric-4.1.1.jar"; };
    yungs-bridges = fetchMod { name = "yungs-bridges"; url = "https://cdn.modrinth.com/data/Ht4BfYp6/versions/Ht4BfYp6/YungsBridges-1.21.1-Fabric-5.1.1.jar"; };
    yungs-cave-biomes = fetchMod { name = "yungs-cave-biomes"; url = "https://cdn.modrinth.com/data/cs7iGVq1/versions/cs7iGVq1/YungsCaveBiomes-1.21.1-Fabric-3.1.1.jar"; };
    yungs-extras = fetchMod { name = "yungs-extras"; url = "https://cdn.modrinth.com/data/ZYgyPyfq/versions/ZYgyPyfq/YungsExtras-1.21.1-Fabric-5.1.1.jar"; };
    wthit = fetchMod { name = "wthit"; url = "https://cdn.modrinth.com/data/6AQIaxuO/versions/6AQIaxuO/wthit-1.21.1-fabric-12.10.2.jar"; };
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

        symlinks = lib.mapAttrs' (name: value: lib.nameValuePair "mods/${name}.jar" value) mods;

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

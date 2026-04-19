{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.game-servers.minecraft-mca;
  
  # Helper to fetch mods. Using lib.fakeHash to force Nix to tell us the correct ones.
  fetchMod = { name, url, hash ? lib.fakeHash }: pkgs.fetchurl {
    inherit url;
    sha256 = hash;
    name = "${name}.jar";
  };

  # Complete Server-Side Mod List for 1.21.1
  mods = {
    # Core & APIs
    fabric-api = fetchMod { name = "fabric-api"; url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/0.116.10+1.21.1/fabric-api-0.116.10+1.21.1.jar"; };
    architectury = fetchMod { name = "architectury"; url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/13.0.8/architectury-13.0.8-fabric.jar"; };
    cloth-config = fetchMod { name = "cloth-config"; url = "https://cdn.modrinth.com/data/9s6osm5g/versions/15.0.140/cloth-config-15.0.140-fabric.jar"; };
    bad-packets = fetchMod { name = "bad-packets"; url = "https://cdn.modrinth.com/data/ftdbN0KK/versions/0.8.2/badpackets-fabric-0.8.2.jar"; };
    geckolib = fetchMod { name = "geckolib"; url = "https://cdn.modrinth.com/data/8BmcQJ2H/versions/4.8.4/geckolib-fabric-1.21.1-4.8.4.jar"; };
    placeholder-api = fetchMod { name = "placeholder-api"; url = "https://cdn.modrinth.com/data/eXts2L7r/versions/2.4.2+1.21/placeholder-api-2.4.2+1.21.jar"; };

    # Performance
    lithium = fetchMod { name = "lithium"; url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/0.15.3+mc1.21.1/lithium-fabric-0.15.3+mc1.21.1.jar"; };
    ferritecore = fetchMod { name = "ferritecore"; url = "https://cdn.modrinth.com/data/uXXizFIs/versions/7.0.3/ferritecore-7.0.3-fabric.jar"; };

    # Gameplay & Content
    farmers-delight = fetchMod { name = "farmers-delight"; url = "https://cdn.modrinth.com/data/7vxePowz/versions/1.21.1-3.2.8+refabricated/FarmersDelight-1.21.1-3.2.8+refabricated.jar"; };
    mca-reborn = fetchMod { name = "mca-reborn"; url = "https://cdn.modrinth.com/data/1W98a849/versions/7.7.6+1.21.1/mca-fabric-7.7.6+1.21.1.jar"; };

    # World Gen
    ctov = fetchMod { name = "ctov"; url = "https://cdn.modrinth.com/data/fgmhI8kH/versions/3.6.3/%5BFabric%5Dctov-3.6.3.jar"; };
    tectonic = fetchMod { name = "tectonic"; url = "https://cdn.modrinth.com/data/lWDHr9jE/versions/3.0.21/tectonic-3.0.21-fabric-21.1.jar"; };
    terralith = fetchMod { name = "terralith"; url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/2.5.8/Terralith_1.21.x_v2.5.8.jar"; };
    terrablender = fetchMod { name = "terrablender"; url = "https://cdn.modrinth.com/data/kkmrDlKT/versions/4.1.0.8/TerraBlender-fabric-1.21.1-4.1.0.8.jar"; };
    lithostitched = fetchMod { name = "lithostitched"; url = "https://cdn.modrinth.com/data/XaDC71GB/versions/1.6.3/lithostitched-1.6.3-fabric-21.1.jar"; };

    # YUNG's Suite
    yungs-api = fetchMod { name = "yungs-api"; url = "https://cdn.modrinth.com/data/Ua7DFN59/versions/1.21.1-Fabric-5.1.6/YungsApi-1.21.1-Fabric-5.1.6.jar"; };
    yungs-caves = fetchMod { name = "yungs-caves"; url = "https://cdn.modrinth.com/data/Dfu00ggU/versions/1.21.1-Fabric-3.1.4/YungsBetterCaves-1.21.1-Fabric-3.1.4.jar"; };
    yungs-desert-temples = fetchMod { name = "yungs-desert-temples"; url = "https://cdn.modrinth.com/data/XNlO7sBv/versions/1.21.1-Fabric-4.1.5/YungsBetterDesertTemples-1.21.1-Fabric-4.1.5.jar"; };
    yungs-dungeons = fetchMod { name = "yungs-dungeons"; url = "https://cdn.modrinth.com/data/o1C1Dkj5/versions/1.21.1-Fabric-5.1.4/YungsBetterDungeons-1.21.1-Fabric-5.1.4.jar"; };
    yungs-jungle-temples = fetchMod { name = "yungs-jungle-temples"; url = "https://cdn.modrinth.com/data/z9Ve58Ih/versions/1.21.1-Fabric-3.1.2/YungsBetterJungleTemples-1.21.1-Fabric-3.1.2.jar"; };
    yungs-mineshafts = fetchMod { name = "yungs-mineshafts"; url = "https://cdn.modrinth.com/data/HjmxVlSr/versions/1.21.1-Fabric-5.1.1/YungsBetterMineshafts-1.21.1-Fabric-5.1.1.jar"; };
    yungs-nether-fortresses = fetchMod { name = "yungs-nether-fortresses"; url = "https://cdn.modrinth.com/data/Z2mXHnxP/versions/1.21.1-Fabric-3.1.5/YungsBetterNetherFortresses-1.21.1-Fabric-3.1.5.jar"; };
    yungs-ocean-monuments = fetchMod { name = "yungs-ocean-monuments"; url = "https://cdn.modrinth.com/data/3dT9sgt4/versions/1.21.1-Fabric-4.1.2/YungsBetterOceanMonuments-1.21.1-Fabric-4.1.2.jar"; };
    yungs-strongholds = fetchMod { name = "yungs-strongholds"; url = "https://cdn.modrinth.com/data/kidLKymU/versions/1.21.1-Fabric-5.1.3/YungsBetterStrongholds-1.21.1-Fabric-5.1.3.jar"; };
    yungs-witch-huts = fetchMod { name = "yungs-witch-huts"; url = "https://cdn.modrinth.com/data/t5FRdP87/versions/1.21.1-Fabric-4.1.1/YungsBetterWitchHuts-1.21.1-Fabric-4.1.1.jar"; };
    yungs-bridges = fetchMod { name = "yungs-bridges"; url = "https://cdn.modrinth.com/data/Ht4BfYp6/versions/1.21.1-Fabric-5.1.1/YungsBridges-1.21.1-Fabric-5.1.1.jar"; };
    yungs-cave-biomes = fetchMod { name = "yungs-cave-biomes"; url = "https://cdn.modrinth.com/data/cs7iGVq1/versions/1.21.1-Fabric-3.1.1/YungsCaveBiomes-1.21.1-Fabric-3.1.1.jar"; };
    yungs-extras = fetchMod { name = "yungs-extras"; url = "https://cdn.modrinth.com/data/ZYgyPyfq/versions/1.21.1-Fabric-5.1.1/YungsExtras-1.21.1-Fabric-5.1.1.jar"; };
    wthit = fetchMod { name = "wthit"; url = "https://cdn.modrinth.com/data/6AQIaxuO/versions/12.10.2/wthit-1.21.1-fabric-12.10.2.jar"; };
  };
in
{
  # Auto-scanned by modules/default.nix
  options.myFeatures.services.game-servers.minecraft-mca = {
    enable = lib.mkEnableOption "Minecraft MCA Reborn Server Instance";
    address = lib.mkOption { type = lib.types.str; default = "0.0.0.0"; };
    port = lib.mkOption { type = lib.types.port; default = 25566; };
  };

  config = lib.mkIf cfg.enable {
    # Overlay for nix-minecraft packages
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers.mca-reborn = {
        enable = true;
        package = pkgs.minecraftServers.fabric-1_21_1;
        jvmOpts = lib.mkDefault "-Xmx8G -Xms8G -Djava.awt.headless=true";

        # Map the full mod list to the mods directory
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

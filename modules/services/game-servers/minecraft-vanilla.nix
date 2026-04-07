# modules/services/game-servers/minecraft-vanilla.nix
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.game-servers.minecraft-vanilla;
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.game-servers.minecraft-vanilla = {
    enable = lib.mkEnableOption "Minecraft Vanilla+ (Terralith/Distant Horizons)";
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers.vanilla-plus = {
        enable = true;
        # Using Fabric for Distant Horizons / Terralith support
        package = pkgs.minecraftServers.fabric-1_21_11; 
        jvmOpts = "-Xmx6G -Xms6G"; # Increased for world-gen mods
        serverProperties = {
          server-port = 25565;
          motd = "Solar Vanilla+ | Terralith & Tectonic";
          level-type = "minecraft:normal"; # Terralith/Tectonic handle this via datapacks
        };
      };
    };
  };
}

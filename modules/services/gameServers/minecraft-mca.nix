# modules/services/game-servers/minecraft-mca.nix
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.game-servers.minecraft-mca;
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.game-servers.minecraft-mca = {
    enable = lib.mkEnableOption "Minecraft MCA Reborn (4 Player)";
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers.mca-reborn = {
        enable = true;
        package = pkgs.minecraftServers.fabric-1_21_1;
        jvmOpts = "-Xmx4G -Xms4G";
        serverProperties = {
          server-port = 25566;
          motd = "Solar MCA Reborn | Family & Friends";
          max-players = 4;
        };
      };
    };
  };
}

{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.game-servers.minecraft-vanilla;
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.game-servers.minecraft-vanilla = {
    enable = lib.mkEnableOption "Minecraft Vanilla+ (Terralith/Distant Horizons)";
    port = lib.mkOption { type = lib.types.port; default = 25565; };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers.vanilla-plus = {
        enable = true;
        package = pkgs.minecraftServers.fabric-1_21_1; 
        jvmOpts = "-Xmx6G -Xms6G";
        serverProperties = {
          server-port = cfg.port;
          motd = "Solar Vanilla+ | Terralith & Tectonic";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}

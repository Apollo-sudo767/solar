{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.game-servers.minecraft-mca;
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
        
        jvmOpts = "-Xmx8G -Xms8G";
        serverProperties = {
          server-ip = cfg.address;
          server-port = cfg.port;
          motd = "Solar MCA Reborn | Family & Friends";
          max-players = 4;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}

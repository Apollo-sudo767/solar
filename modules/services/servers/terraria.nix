{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.servers.terraria;
  # We create a server config file to force non-interactive mode
  serverConfig = pkgs.writeText "serverconfig.txt" ''
    port=${toString cfg.port}
    maxplayers=${toString cfg.maxPlayers}
    password=${cfg.password}
    world=/var/lib/terraria/Worlds/SolarWorld.wld
    worldname=SolarWorld
    autocreate=${if cfg.worldSize == "small" then "1" else if cfg.worldSize == "medium" then "2" else "3"}
    difficulty=1
    secure=1
    upnp=0
  '';
in
{
  # --- OPTIONS ---
  options.myFeatures.services.servers.terraria = {
    enable = lib.mkEnableOption "Terraria Dedicated Server (Direct)";
    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
    };
    password = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    maxPlayers = lib.mkOption {
      type = lib.types.int;
      default = 8;
    };
    worldSize = lib.mkOption { 
      type = lib.types.enum [ "small" "medium" "large" ]; 
      default = "large"; 
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.terraria = {
      description = "Terraria Server (Solar Managed)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "terraria";
        Group = "terraria";
        StateDirectory = "terraria";
        WorkingDirectory = "/var/lib/terraria";
        
        # We point to the config file which bypasses the interactive menu
        ExecStart = "${pkgs.terraria-server}/bin/TerrariaServer -config ${serverConfig}";
        Restart = "on-failure";
      };
    };

    users.users.terraria = {
      isSystemUser = true;
      group = "terraria";
      home = "/var/lib/terraria";
    };
    users.groups.terraria = {};
  };
}

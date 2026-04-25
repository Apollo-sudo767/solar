{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.servers.terraria;
  
  # We create a server config file to force non-interactive mode.
  # NOTE: This file is stored in the Nix Store (/nix/store/...) and is world-readable.
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
  options.myFeatures.services.servers.terraria = {
    enable = lib.mkEnableOption "Terraria Dedicated Server (Solar Managed)";
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

  config = lib.mkIf cfg.enable {
    # Port management via host default.nix logic
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
        
        # StateDirectory automatically handles /var/lib/terraria creation
        StateDirectory = "terraria";
        WorkingDirectory = "/var/lib/terraria";
        
        # Direct execution bypassing the interactive menu
        ExecStart = "${pkgs.terraria-server}/bin/TerrariaServer -config ${serverConfig}";
        
        # Stability & Protection against CPU leaks
        Restart = "always";
        RestartSec = "10s";
        CPUQuota = "20%"; # Hard cap to prevent the 12%+ hang from impacting venus
        MemoryMax = "2G";
        
        # Security Hardening
        ProtectSystem = "full";
        NoNewPrivileges = true;
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

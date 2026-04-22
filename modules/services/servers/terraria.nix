{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.servers.terraria;
in
{
  # --- OPTIONS ---
  options.myFeatures.services.servers.terraria = {
    enable = lib.mkEnableOption "Terraria Dedicated Server (Direct)";
    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = "The port the Terraria server will listen on.";
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
    # 1. Firewall Management
    # Uses the configured port dynamically
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    # 2. Direct Systemd Service (Bypassing Tmux)
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
        
        # ExecStart uses the binary directly to ensure logs hit journalctl
        ExecStart = ''
          ${pkgs.terraria-server}/bin/TerrariaServer \
            -port ${toString cfg.port} \
            -players ${toString cfg.maxPlayers} \
            -pass "${cfg.password}" \
            -worldname "SolarWorld" \
            -autocreate ${if cfg.worldSize == "small" then "1" else if cfg.worldSize == "medium" then "2" else "3"} \
            -logpath /var/lib/terraria/logs
        '';
        Restart = "on-failure";
      };
    };

    # 3. Dedicated System User
    users.users.terraria = {
      isSystemUser = true;
      group = "terraria";
      home = "/var/lib/terraria";
    };
    users.groups.terraria = {};
  };
}

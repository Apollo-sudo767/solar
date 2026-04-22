{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.servers.terraria;
in
{
  # --- OPTIONS ---
  options.myFeatures.services.servers.terraria = {
    enable = lib.mkEnableOption "Terraria Dedicated Server";
    password = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Server password. If empty, no password is required.";
    };
    maxPlayers = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Maximum number of players.";
    };
    # Corrected world size enum to use strings as required
    worldSize = lib.mkOption {
      type = lib.types.enum [ "small" "medium" "large" ];
      default = "large"; 
      description = "Size of the world to create.";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically open the Terraria port (7777) in the firewall.";
    };
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    services.terraria = {
      enable = true;
      package = pkgs.terraria-server;
      
      port = 7777;
      maxPlayers = cfg.maxPlayers;
      password = cfg.password;
      openFirewall = cfg.openFirewall;

      # Corrected option names for NixOS services.terraria
      autoCreatedWorldSize = cfg.worldSize;
    };

    # Logic & Debugging: Ensure state directory is managed by systemd
    systemd.services.terraria.serviceConfig.StateDirectory = "terraria";
  };
}

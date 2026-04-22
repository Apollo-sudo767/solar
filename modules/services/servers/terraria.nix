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
    # New option for world size: 1 (small), 2 (medium), 3 (large)
    worldSize = lib.mkOption {
      type = lib.types.enum [ "small" "medium" "large" ];
      default = 3; 
      description = "Size of the world to create: 1 (Small), 2 (Medium), 3 (Large).";
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

      # World Generation Settings
      autoCreatedWorldSize = cfg.worldSize; # Set to 3 for max (Large) size
    };
  };
}

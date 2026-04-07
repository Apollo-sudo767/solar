{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.game-servers.factorio;
in
{
  options.myFeatures.services.game-servers.factorio = {
    enable = lib.mkEnableOption "Factorio Headless Server";
    # Option to set the IP/Interface to bind to
    bind = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0"; 
      description = "IP address to bind the server to (use [::] for IPv6)";
    };
    # Option to set a custom port
    port = lib.mkOption {
      type = lib.types.port;
      default = 34197;
      description = "UDP port for the Factorio server";
    };
  };

  config = lib.mkIf cfg.enable {
    services.factorio = {
      enable = true;
      openFirewall = true; # Automatically opens the UDP port in the firewall
      
      # Map your new module options to the actual Factorio service
      inherit (cfg) bind port;
    };
  };
}

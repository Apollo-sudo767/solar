{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.nginx;
in {
  options.myFeatures.services.nginx = {
    enable = lib.mkEnableOption "Nginx Reverse Proxy";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "pluto.local"; # Change this to your actual domain
    };
  };

  config = lib.mkIf cfg.enable {
    # Open standard web ports in the firewall
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080"; # Points to your Anytype Sync port
          proxyWebsockets = true; # Needed for many modern sync services
        };
      };
    };

    # Automatically handle SSL certificate renewal
    security.acme = {
      acceptTerms = true;
    };
  };
}

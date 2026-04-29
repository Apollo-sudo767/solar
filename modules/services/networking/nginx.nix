{ config, lib, ... }:

let
  cfg = config.myFeatures.services.nginx;
in
{
  options.myFeatures.services.nginx = {
    enable = lib.mkEnableOption "Nginx Reverse Proxy";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "pluto.local";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "apollo@apollan.cc"; # Reasonable default
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}

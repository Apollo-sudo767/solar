{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.silverbullet;
in
{
  options.myFeatures.services.servers.silverbullet = {
    enable = lib.mkEnableOption "SilverBullet Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port to listen on.";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "sb.apollan.cc";
      description = "Domain for SilverBullet.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.silverbullet = {
      enable = true;
      listenPort = cfg.port;
      spaceDir = "/var/lib/silverbullet";
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = lib.mkDefault true;
      forceSSL = lib.mkDefault true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}

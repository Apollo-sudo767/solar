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
    authTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = "/var/lib/secrets/silverbullet-auth";
      description = "Path to a file containing the SB_AUTH_TOKEN.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.silverbullet = {
      enable = true;
      listenPort = cfg.port;
      listenAddress = "127.0.0.1"; # Only listen on localhost as we use Nginx
      spaceDir = "/var/lib/silverbullet";
    };

    systemd.services.silverbullet.serviceConfig = {
      Environment = [
        "SB_CHROME_PATH=${pkgs.chromium}/bin/chromium"
        "SB_BASE_URL=https://${cfg.domain}"
      ];
      EnvironmentFile = lib.optional (cfg.authTokenFile != null) cfg.authTokenFile;
      StateDirectory = "silverbullet";
    };

    services.nginx.virtualHosts."${cfg.domain}" = {
      enableACME = lib.mkDefault true;
      forceSSL = lib.mkDefault true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.services.servers.zotero;
  rawHost = lib.replaceStrings [ "https://" "http://" ] [ "" "" ] cfg.baseUrl;
  domainName = lib.head (lib.splitString "/" rawHost);
in
{
  options.myFeatures.services.servers.zotero = {
    enable = lib.mkEnableOption "Zotero WebDAV Attachment Server (Solar Managed)";
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://zotero.apollan.cc";
      description = "Public base URL of Zotero WebDAV host.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Listening port for Zotero WebDAV server.";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/zotero-webdav";
      description = "Storage path for Zotero WebDAV attachment files.";
    };
    username = lib.mkOption {
      type = lib.types.str;
      default = "zotero";
      description = "WebDAV authentication username for Zotero client attachment sync.";
    };
    password = lib.mkOption {
      type = lib.types.str;
      default = "zotero";
      description = "WebDAV authentication password for Zotero client attachment sync.";
    };
    nginx = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Nginx virtualHost proxy for Zotero WebDAV host.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0770 webdav webdav -"
        "d ${cfg.dataDir}/zotero 0770 webdav webdav -"
      ];

      services.webdav = {
        enable = true;
        settings = {
          address = "0.0.0.0";
          inherit (cfg) port;
          scope = cfg.dataDir;
          modify = true;
          auth = true;
          cors = {
            enabled = true;
            credentials = true;
            allowed_hosts = [ "*" ];
          };
          users = [
            {
              inherit (cfg) username;
              inherit (cfg) password;
              scope = cfg.dataDir;
              modify = true;
            }
          ];
        };
      };

      services.nginx = lib.mkIf cfg.nginx.enable {
        enable = true;
        virtualHosts."${domainName}" = {
          enableACME = lib.mkDefault (!lib.hasSuffix ".local" domainName);
          forceSSL = lib.mkDefault (!lib.hasSuffix ".local" domainName);
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}/";
            proxyWebsockets = true;
            extraConfig = ''
              # Strip/fix Origin header for WebDAV to prevent "Invalid origin" error
              proxy_set_header Origin "";

              # Essential WebDAV proxy headers
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;

              # Disable body size limits for uploading large PDFs
              client_max_body_size 0;
            '';
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    }
  );
}

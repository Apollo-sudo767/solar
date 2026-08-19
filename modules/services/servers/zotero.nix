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
  # Bcrypt hash for default password "zotero" (hacdias/webdav requires {bcrypt} prefix)
  defaultZoteroBcrypt = "{bcrypt}$2a$10$39wq30lPabYwZN1.LTchG.dMXAG.U.qBvD7xa0mF.OQoVskT7i7/K";

  effectivePasswordHash =
    if cfg.passwordHash != null then
      if lib.hasPrefix "{bcrypt}" cfg.passwordHash then
        cfg.passwordHash
      else if lib.hasPrefix "$2" cfg.passwordHash then
        "{bcrypt}${cfg.passwordHash}"
      else
        cfg.passwordHash
    else if lib.hasPrefix "{bcrypt}" cfg.password then
      cfg.password
    else if lib.hasPrefix "$2" cfg.password then
      "{bcrypt}${cfg.password}"
    else if cfg.password == "zotero" then
      defaultZoteroBcrypt
    else
      cfg.password;
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
      description = "WebDAV authentication password or bcrypt hash for Zotero client attachment sync.";
    };
    passwordHash = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional pre-hashed bcrypt string for WebDAV authentication ($2a$...).";
    };
    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to custom WebDAV config YAML file on server disk. Overrides declarative settings if set, allowing runtime user/password management outside Nix.";
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
        "d ${cfg.dataDir} 0775 webdav webdav -"
        "d ${cfg.dataDir}/zotero 0775 webdav webdav -"
        "f+ ${cfg.dataDir}/zotero/lastsync.txt 0664 webdav webdav - 1724000000"
        "f+ ${cfg.dataDir}/lastsync.txt 0664 webdav webdav - 1724000000"
      ];

      services.webdav = lib.mkMerge [
        {
          enable = true;
        }
        (lib.mkIf (cfg.configFile != null) {
          inherit (cfg) configFile;
        })
        (lib.mkIf (cfg.configFile == null) {
          settings = {
            address = "0.0.0.0";
            inherit (cfg) port;
            scope = "${cfg.dataDir}/zotero";
            modify = true;
            auth = true;
            cors = {
              enabled = true;
              credentials = true;
              allowed_origins = [ "*" ];
              allowed_headers = [ "*" ];
              allowed_methods = [
                "GET"
                "HEAD"
                "POST"
                "PUT"
                "PATCH"
                "DELETE"
                "MKCOL"
                "PROPFIND"
                "PROPPATCH"
                "COPY"
                "MOVE"
                "OPTIONS"
              ];
            };
            users = [
              {
                inherit (cfg) username;
                password = effectivePasswordHash;
                scope = ".";
                modify = true;
                permissions = "CRUD";
              }
            ];
          };
        })
      ];

      services.nginx = lib.mkIf cfg.nginx.enable {
        enable = true;
        virtualHosts."${domainName}" = {
          enableACME = lib.mkDefault (!lib.hasSuffix ".local" domainName);
          forceSSL = lib.mkDefault (!lib.hasSuffix ".local" domainName);
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
            extraConfig = ''
              # Strip any /zotero or /zotero/zotero prefix so all requests map to WebDAV root
              rewrite ^/zotero/zotero/(.*)$ /$1 break;
              rewrite ^/zotero/zotero/?$ / break;
              rewrite ^/zotero/(.*)$ /$1 break;
              rewrite ^/zotero/?$ / break;

              # Ensure redirect Location headers use https
              proxy_redirect http:// https://;

              # Strip Origin header for WebDAV to prevent "Invalid origin" CORS error
              proxy_set_header Origin "";

              # Essential WebDAV proxy headers
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;

              # Additional WebDAV headers for file movement/properties
              proxy_set_header Depth $http_depth;
              proxy_set_header Destination $http_destination;
              proxy_set_header Overwrite $http_overwrite;

              # Disable request/response buffering for WebDAV operations
              proxy_buffering off;
              proxy_request_buffering off;

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

{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.nginx;
in
{
  options.myFeatures.services.nginx = {
    enable = lib.mkEnableOption "Nginx Reverse Proxy";
    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default domain for Nginx (optional).";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.nginx = {
        enable = true;
        virtualHosts = lib.mkIf (cfg.domain != null) {
          "${cfg.domain}" = {
            enableACME = lib.mkDefault (!lib.hasSuffix ".local" cfg.domain);
            forceSSL = lib.mkDefault (!lib.hasSuffix ".local" cfg.domain);
            locations."/" = {
              proxyPass = "http://127.0.0.1:8080";
              proxyWebsockets = true;
            };
          };
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults = {
          email = "apollo@apollan.cc";
          dnsProvider = "cloudflare";
          # Use the same token file as DDNS
          credentialFiles = {
            "CLOUDFLARE_DNS_API_TOKEN_FILE" = "/var/lib/secrets/cloudflare-token";
          };
        };
        # Explicitly override the webroot for apollan.cc domains to use DNS-01
        certs = lib.listToAttrs (
          map (domain: {
            name = domain;
            value = {
              dnsProvider = "cloudflare";
              webroot = lib.mkForce null;
            };
          }) (lib.filter (d: lib.hasSuffix "apollan.cc" d) (lib.attrNames config.services.nginx.virtualHosts))
        );
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    }
  );
}

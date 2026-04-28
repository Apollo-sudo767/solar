{ config, lib, ... }:

let
  cfg = config.myFeatures.services.networking.cloudflare;
in
{
  options.myFeatures.services.networking.cloudflare = {
    enable = lib.mkEnableOption "Cloudflare Tunnel";
    tunnelId = lib.mkOption {
      type = lib.types.str;
      description = "The UUID of your Cloudflare tunnel";
    };
    credentialsFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/cloudflare/tunnel-creds.json";
      description = "Local path to the tunnel JSON credentials";
    };
    domains = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "git.example.com" = "http://localhost:3000";
      };
    };
  };

  # Shield the NixOS-only service from the macOS evaluator
  config = lib.mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels."${cfg.tunnelId}" = {
        inherit (cfg) credentialsFile;
        ingress =
          (lib.mapAttrsToList (hostname: service: {
            inherit hostname service;
          }) cfg.domains)
          ++ [ { default = "http_status:404"; } ];
      };
    };
  };
}

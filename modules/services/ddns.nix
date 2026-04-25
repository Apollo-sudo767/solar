{ config, lib, isDarwin, ... }: # Added isDarwin

let
  cfg = config.myFeatures.services.ddns;
in
{
  options.myFeatures.services.ddns = {
    enable = lib.mkEnableOption "Cloudflare DDNS";
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of apollan.cc subdomains to update";
    };
  };

  # Shield the Linux-only Cloudflare service from macOS
  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    services.cloudflare-dyndns = {
      enable = true;
      inherit (cfg) domains;
      # Point to your manually created token file
      apiTokenFile = "/var/lib/secrets/cloudflare-token";
    };
  });
}

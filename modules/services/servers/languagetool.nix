# modules/services/servers/languagetool.nix
# ============================================================================
# LanguageTool Self-Hosted Proofreading API Server
# ============================================================================
# Runs a local/self-hosted LanguageTool HTTP API server on Linux and opens its
# configured TCP port in the firewall.
{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.servers.languagetool;
in
{
  options.myFeatures.services.servers.languagetool = {
    enable = lib.mkEnableOption "LanguageTool Self-Hosted Proofreading API Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8010;
      description = "Listening port for LanguageTool HTTP API server.";
    };
    allowOrigin = lib.mkOption {
      type = lib.types.str;
      default = "*";
      description = "Allowed origin header value for CORS access.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.languagetool = {
        enable = true;
        inherit (cfg) port allowOrigin;
        public = true;
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    }
  );
}

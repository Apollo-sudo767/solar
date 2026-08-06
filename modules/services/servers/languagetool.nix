{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
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
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://languagetool.apollan.cc";
      description = "Public base URL of self-hosted LanguageTool server.";
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
        inherit (cfg) port;
        inherit (cfg) allowOrigin;
        public = true;
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    }
  );
}

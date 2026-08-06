{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.services.servers.trilium;
in
{
  options.myFeatures.services.servers.trilium = {
    enable = lib.mkEnableOption "Trilium Server (Solar Managed)";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the Trilium server";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.trilium-server = {
        enable = true;
        inherit (cfg) port;
        host = "0.0.0.0";
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    }
  );
}

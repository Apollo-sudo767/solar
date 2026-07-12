{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.services.servers.trilium;
in
{
  options.myFeatures.services.servers.trilium = {
    enable = lib.mkEnableOption "Trilium (Solar Managed)";
    type = lib.mkOption {
      type = lib.types.enum [
        "server"
        "desktop"
      ];
      default = "server";
      description = "Whether to deploy the background server version or the desktop client application.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the Trilium server (only applicable in server mode)";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.trilium-server = lib.mkIf (cfg.type == "server") {
          enable = true;
          inherit (cfg) port;
        };

        networking.firewall.allowedTCPPorts = lib.mkIf (cfg.type == "server") [ cfg.port ];

        environment.systemPackages = lib.mkIf (cfg.type == "desktop") [ pkgs.trilium-desktop ];
      })
      (lib.optionalAttrs isDarwin {
        environment.systemPackages = [
          (if cfg.type == "server" then pkgs.trilium-server else pkgs.trilium-desktop)
        ];
      })
    ]
  );
}

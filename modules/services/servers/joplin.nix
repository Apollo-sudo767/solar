{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.servers.joplin;
in
{
  imports = [
    inputs.joplin-server.nixosModules.default
  ];

  options.myFeatures.services.servers.joplin = {
    enable = lib.mkEnableOption "Joplin Synchronization Server & Desktop (Solar Managed)";
    type = lib.mkOption {
      type = lib.types.enum [
        "server"
        "desktop"
        "both"
      ];
      default = "both";
      description = "Whether to deploy the Joplin Server service or the Joplin Desktop client.";
    };
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:22300";
      description = "Public base URL of Joplin Server.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 22300;
      description = "Listening port for Joplin Server.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.joplin-server = lib.mkIf (cfg.type == "server" || cfg.type == "both") {
          enable = true;
          inherit (cfg) baseUrl port;
          database.createLocally = true;
        };

        networking.firewall.allowedTCPPorts = lib.mkIf (cfg.type == "server" || cfg.type == "both") [
          cfg.port
        ];

        environment.systemPackages = lib.mkIf (cfg.type == "desktop" || cfg.type == "both") [
          pkgs.joplin-desktop
        ];
      })
      (lib.optionalAttrs isDarwin {
        environment.systemPackages = [ pkgs.joplin-desktop ];
      })
    ]
  );
}

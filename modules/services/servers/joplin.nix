{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.services.servers.joplin;
  isServerType = cfg.type == "server" || cfg.type == "both" || cfg.type == "all";
  isDesktopType = cfg.type == "desktop" || cfg.type == "both" || cfg.type == "all";
  isCliType = cfg.cli || cfg.type == "cli" || cfg.type == "all";
in
{
  imports = lib.optional (!isDarwin) inputs.joplin-server.nixosModules.default;

  options.myFeatures.services.servers.joplin = {
    enable = lib.mkEnableOption "Joplin Synchronization Server, Desktop, & CLI (Solar Managed)";
    type = lib.mkOption {
      type = lib.types.enum [
        "server"
        "desktop"
        "both"
        "cli"
        "all"
      ];
      default = "both";
      description = "Whether to deploy the Joplin Server service, Joplin Desktop client, CLI, or all.";
    };
    cli = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the Joplin CLI client.";
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
        services.joplin-server = lib.mkIf isServerType {
          enable = true;
          inherit (cfg) baseUrl port;
          database.createLocally = true;
        };

        networking.firewall.allowedTCPPorts = lib.mkIf isServerType [ cfg.port ];
      })
      {
        environment.systemPackages =
          (lib.optional isDesktopType pkgs.joplin-desktop) ++ (lib.optional isCliType pkgs.joplin-cli);
      }
    ]
  );
}

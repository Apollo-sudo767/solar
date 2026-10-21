# modules/services/servers/joplin.nix
#
# Configures the self-hosted Joplin synchronization server (`joplin-server`)
# with local PostgreSQL database and Nginx virtualHost support on NixOS.
{
  config,
  lib,
  inputs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.servers.joplin;
in
{
  imports = lib.optional (!isDarwin) inputs.joplin-server.nixosModules.default;

  options.myFeatures.services.servers.joplin = {
    enable = lib.mkEnableOption "Joplin Synchronization Server (Solar Managed)";
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://joplin.apollan.cc";
      description = "Public base URL of Joplin Server.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 22300;
      description = "Listening port for Joplin Server.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.joplin-server = {
        enable = true;
        inherit (cfg) baseUrl port;
        database.createLocally = true;
        nginx.enable = true;
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    }
  );
}

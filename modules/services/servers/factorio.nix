# modules/services/servers/factorio.nix
# ============================================================================
# Factorio Dedicated Headless Server
# ============================================================================
# Runs a headless Factorio game server on Linux and automatically opens the
# configured UDP port in the firewall via `services.factorio.openFirewall`.
{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.servers.factorio;
in
{
  options.myFeatures.services.servers.factorio = {
    enable = lib.mkEnableOption "Factorio Headless Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 34197;
      description = "UDP port for the Factorio server";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (!isDarwin) {
      services.factorio = {
        enable = true;
        openFirewall = true;
        inherit (cfg) port;
      };
    }
  );
}

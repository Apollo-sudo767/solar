{ config, lib, pkgs, isDarwin, ... }:

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

  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    services.factorio = {
      enable = true;
      openFirewall = true;
      # bind is not a standard option; port is.
      inherit (cfg) port;
    };

    networking.firewall.allowedUDPPorts = [ cfg.port ];
  });
}

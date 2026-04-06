# modules/services/game-servers/factorio.nix
{ config, lib, ... }:

let
  cfg = config.myFeatures.services.game-servers.factorio;
in
{
  options.myFeatures.services.game-servers.factorio.enable = lib.mkEnableOption "Factorio Server";

  config = lib.mkIf cfg.enable {
    services.factorio = {
      enable = true;
      openFirewall = false; # Cloudflare handles the entry point
    };
  };
}

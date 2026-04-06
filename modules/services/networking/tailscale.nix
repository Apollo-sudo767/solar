{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.networking.tailscale;
in
{
  options.myFeatures.core.services.tailscale = {
    enable = lib.mkEnableOption "Tailscale Mesh VPN";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    
    # Standard Solar Practice: Trust the tailscale interface
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    
    # Allow the Tailscale UDP port through the firewall
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  };
}

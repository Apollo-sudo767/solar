{ config, lib, pkgs, isDarwin, ... }: # Added isDarwin [cite: 208]

let
  cfg = config.myFeatures.services.networking.tailscale;
in
{
  options.myFeatures.services.networking.tailscale = {
    enable = lib.mkEnableOption "Tailscale Mesh VPN";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { services.tailscale.enable = true; }
    
    # Shield firewall rules from macOS [cite: 211]
    (lib.optionalAttrs (!isDarwin) {
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
    })
  ]);
}

{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.networking.tailscale;
in
{
  options.myFeatures.services.networking.tailscale = {
    enable = lib.mkEnableOption "Tailscale Mesh VPN";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { services.tailscale.enable = true; }

      # ACTUALLY Shield firewall rules from macOS!
      (lib.optionalAttrs (!isDarwin) {
        networking.firewall.trustedInterfaces = [ "tailscale0" ];
        networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
      })
    ]
  );
}

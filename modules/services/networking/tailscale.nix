{
  config,
  lib,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.services.networking.tailscale;
in
{
  options.myFeatures.services.networking.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. Common configuration for both Mac and Linux
      {
        services.tailscale.enable = true;
      }

      # 2. Linux-only configuration
      (lib.optionalAttrs (!isDarwin) {
        # You could add things like --accept-dns=false here if needed
      })
    ]
  );
}

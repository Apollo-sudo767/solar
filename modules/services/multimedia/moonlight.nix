# modules/services/multimedia/moonlight.nix
# ============================================================================
# Moonlight Game Streaming Client
# ============================================================================
# Installs the Moonlight Qt low-latency game streaming client and enables
# Avahi mDNS discovery on Linux so local Sunshine hosts are discovered
# automatically on the LAN.
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.multimedia.moonlight;
in
{
  options.myFeatures.services.multimedia.moonlight = {
    enable = lib.mkEnableOption "Moonlight: High-performance game streaming client";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { environment.systemPackages = [ pkgs.moonlight-qt ]; }

      (lib.optionalAttrs (!isDarwin) {
        services.avahi = {
          enable = true;
          nssmdns4 = true;
        };
      })
    ]
  );
}

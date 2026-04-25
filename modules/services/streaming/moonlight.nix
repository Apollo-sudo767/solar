{ config, lib, pkgs, isDarwin, ... }: # Added isDarwin [cite: 212]

let
  cfg = config.myFeatures.services.streaming.moonlight;
in
{
  options.myFeatures.services.streaming.moonlight = {
    enable = lib.mkEnableOption "Moonlight: High-performance game streaming client";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { environment.systemPackages = [ pkgs.moonlight-qt ]; }

    (lib.optionalAttrs (!isDarwin) {
      networking.firewall = {
        allowedUDPPorts = [ 1900 5353 ];
        allowedTCPPorts = [ 47984 47989 48010 ];
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    })
  ]);
}

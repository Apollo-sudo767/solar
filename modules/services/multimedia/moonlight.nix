{ config, lib, pkgs, ... }: # Added pkgs.stdenv.isDarwin [cite: 212]

let
  cfg = config.myFeatures.services.multimedia.moonlight;
in
{
  options.myFeatures.services.multimedia.moonlight = {
    enable = lib.mkEnableOption "Moonlight: High-performance game streaming client";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { environment.systemPackages = [ pkgs.moonlight-qt ]; }

    {
      networking.firewall = {
        allowedUDPPorts = [ 1900 5353 ];
        allowedTCPPorts = [ 47984 47989 48010 ];
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    }
  ]);
}

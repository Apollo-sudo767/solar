{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.moonlight;
in
{
  options.myFeatures.services.moonlight = {
    enable = lib.mkEnableOption "Moonlight: High-performance game streaming client";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.moonlight-qt ];

    # Open discovery ports for the client to find Sunshine hosts
    networking.firewall = {
      allowedUDPPorts = [ 1900 5353 ]; 
      allowedTCPPorts = [ 47984 47989 48010 ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}

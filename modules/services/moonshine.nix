{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.moonlight;
in
{
  options.myFeatures.programs.moonlight = {
    enable = lib.mkEnableOption "Moonlight: High-performance game streaming client";
  };

  config = lib.mkIf cfg.enable {
    # Install the Moonlight-Qt client
    environment.systemPackages = [ pkgs.moonlight-qt ];

    # Ensure the firewall allows discovery of local Sunshine hosts
    networking.firewall = {
      allowedUDPPorts = [ 5353 ]; # mDNS for host discovery
      allowedTCPPorts = [ 47984 47989 48010 ];
    };
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.anytypeSync;
in
{
  options.myFeatures.services.anytypeSync = {
    enable = lib.mkEnableOption "Anytype Sync Node";
  };

  config = lib.mkIf cfg.enable {
    # Enable Docker for the containerized stack
    virtualisation.docker.enable = true;

    # Open necessary ports for Anytype syncing
    networking.firewall = {
      allowedTCPPorts = [ 8080 17336 ]; 
      allowedUDPPorts = [ 443 8000 8001 8002 8003 ];
    };

    # Systemd service to manage the sync node
    systemd.services.anytype-sync = {
      description = "Anytype Sync Node Stack";
      after = [ "network.target" "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.docker-compose}/bin/docker-compose -f /var/lib/anytype/docker-compose.yml up
      '';
      serviceConfig = {
        Restart = "always";
        WorkingDirectory = "/var/lib/anytype";
      };
    };

    # Ensure the working directory exists on activation
    system.activationScripts.anytype-setup = ''
      mkdir -p /var/lib/anytype
    '';
  };
}

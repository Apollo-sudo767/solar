{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.anytype;
in
{
  options.myFeatures.services.anytype = {
    enable = lib.mkEnableOption "Anytype (Anysync) self-hosted server";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/anytype";
      description = "Directory to store Anytype data and configurations.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Docker is enabled for this service
    virtualisation.docker.enable = true;

    # Create the data directory
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
    ];

    # systemd service to run the any-sync stack
    # Note: This uses the official docker-compose approach recommended by Anytype
    systemd.services.anytype-server = {
      description = "Anytype Self-Hosted Network (any-sync)";
      after = [ "network.target" "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = cfg.dataDir;
        # You will need to place your docker-compose.yml in cfg.dataDir
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
        Restart = "always";
      };
    };

    # Open necessary ports for P2P sync and client connectivity
    networking.firewall.allowedTCPPorts = [ 443 8000 8001 8002 8003 ];
    networking.firewall.allowedUDPPorts = [ 443 8000 8001 8002 8003 ];
  };
}

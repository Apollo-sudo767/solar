{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.anytype;
  # Pulling from your flake inputs
  anytype-pkg = inputs.anytype-bundle.packages.${pkgs.system}.default;
in
{
  options.myFeatures.services.anytype = {
    enable = lib.mkEnableOption "Anytype Self-Hosted Sync Network";
    dataDir = lib.mkOption {
      type = lib.types.path; # Changed to path type for better Nix handling
      default = /var/lib/anytype;
      description = "Path to store Anytype databases and configuration.";
    };
    externalAddr = lib.mkOption {
      type = lib.types.str;
      example = "anytype.apollan.cc";
      description = "The public domain clients use to connect.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Dependencies - Anytype Bundle needs Mongo and Redis
    services.mongodb = {
      enable = true;
      package = pkgs.mongodb-ce;
    };
    services.redis.servers.anytype = {
      enable = true;
      port = 6379;
    };

    # 2. Systemd Service
    systemd.services.anytype-server = {
      description = "Anytype Sync Bundle Server";
      after = [ "network.target" "mongodb.service" "redis-anytype.service" ];
      wantedBy = [ "multi-user.target" ];
      
      # Use the automated StateDirectory feature of Systemd
      serviceConfig = {
        StateDirectory = "anytype"; 
        RuntimeDirectory = "anytype";
        User = "anytype";
        Group = "anytype";
        Restart = "always";
        # Path is fixed to the StateDirectory (/var/lib/anytype)
        WorkingDirectory = "/var/lib/anytype";
      };

      # The "Solar" bootstrap logic: Generate config if it's missing
      preStart = ''
        if [ ! -f /var/lib/anytype/config.yml ]; then
          echo "Initializing Anytype Bundle config..."
          ${anytype-pkg}/bin/any-sync-bundle init \
            --external-addr ${cfg.externalAddr}:33010 \
            --output /var/lib/anytype/config.yml
        fi
      '';

      script = ''
        exec ${anytype-pkg}/bin/any-sync-bundle -c /var/lib/anytype/config.yml
      '';
    };

    # 3. Solar Networking
    # Opening the ports for yamux/DRPC and QUIC
    networking.firewall.allowedTCPPorts = [ 33010 ]; 
    networking.firewall.allowedUDPPorts = [ 33020 ];

    # 4. User setup
    users.users.anytype = {
      isSystemUser = true;
      group = "anytype";
    };
    users.groups.anytype = {};
  };
}

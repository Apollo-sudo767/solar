{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.anytype;
  # Use the package from our new flake input
  anytype-pkg = inputs.anytype-bundle.packages.${pkgs.system}.default;
in
{
  options.myFeatures.services.anytype = {
    enable = lib.mkEnableOption "Anytype Self-Hosted Sync Network";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/anytype";
      description = "Path to store Anytype databases and configuration.";
    };
    externalAddr = lib.mkOption {
      type = lib.types.str;
      description = "The public IP or Domain clients use to connect.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Dependencies
    services.mongodb.enable = true;
    services.redis.servers.anytype = {
      enable = true;
      port = 6379;
    };

    # 2. Systemd Service for the Bundle
    systemd.services.anytype-server = {
      description = "Anytype Sync Bundle Server";
      after = [ "network.target" "mongodb.service" "redis-anytype.service" ];
      wantedBy = [ "multi-user.target" ];
      
      environment = {
        # Tells the bundle where to look for its internal config
        ANY_SYNC_BUNDLE_INIT_EXTERNAL_ADDRS = cfg.externalAddr;
      };

      serviceConfig = {
        ExecStart = "${anytype-pkg}/bin/any-sync-bundle -c ${cfg.dataDir}/config.yml";
        Restart = "always";
        User = "anytype";
        Group = "anytype";
        StateDirectory = "anytype";
        WorkingDirectory = cfg.dataDir;
      };
    };

    # 3. Networking
    networking.firewall.allowedTCPPorts = [ 33010 ]; # yamux/DRPC
    networking.firewall.allowedUDPPorts = [ 33020 ]; # QUIC

    # 4. User setup
    users.users.anytype = {
      isSystemUser = true;
      group = "anytype";
      home = cfg.dataDir;
    };
    users.groups.anytype = {};
  };
}

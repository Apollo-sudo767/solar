{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.services.any-sync;
  # community-maintained all-in-one binary
  any-sync-bundle = inputs.anytype-bundle.packages.${pkgs.system}.default;
in
{
  options.myFeatures.services.any-sync = {
    enable = lib.mkEnableOption "Anytype Self-Hosted Sync Server";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/anytype";
      description = "Directory for Anytype sync data and configs";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Required dependencies for the sync server
    services.mongodb.enable = true;
    services.redis.servers."any-sync" = {
      enable = true;
      port = 6379;
    };

    # 2. Networking: Open ports required for Anytype nodes
    networking.firewall.allowedTCPPorts = [ 33010 33030 33060 33080 ];
    networking.firewall.allowedUDPPorts = [ 33020 ]; # QUIC protocol

    # 3. Systemd Service for the bundle
    systemd.services.any-sync = {
      description = "Anytype Self-Hosted Sync Server";
      after = [ "network.target" "mongodb.service" "redis.service" ];
      requires = [ "mongodb.service" "redis.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${any-sync-bundle}/bin/any-sync-bundle start-bundle --config-path ${cfg.dataDir}/bundle-config.yml";
        User = "anytype";
        Group = "anytype";
        StateDirectory = "anytype";
        Restart = "always";
      };
    };

    # 4. Define the dedicated system user
    users.users.anytype = {
      isSystemUser = true;
      group = "anytype";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.anytype = {};
  };
}

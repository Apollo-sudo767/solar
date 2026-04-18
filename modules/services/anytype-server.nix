{ config, lib, ... }:

let
  cfg = config.myfeatures.services.anytype;
in
{
  options.myfeatures.services.anytype = {
    enable = lib.mkenableoption "anytype self-hosted network";
    externaladdr = lib.mkoption {
      type = lib.types.str;
      default = "anytype.apollan.cc";
    };
  };

  config = lib.mkif cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    
    virtualisation.oci-containers.containers = {
      # 1. the sync node
      anytype-sync = {
        image = "docker.io/anyproto/any-sync-node:latest";
        ports = [ "33010:33010" "33020:33020/udp" ];
        volumes = [ "/var/lib/anytype/storage:/etc/any-sync" ];
        environment = {
          "any_sync_mongodb_connection" = "mongodb://anytype-mongo:27017";
          "any_sync_redis_connection" = "redis://anytype-redis:6379";
        };
        extraoptions = [ "--restart=always" ];
        dependson = [ "anytype-mongo" "anytype-redis" ];
      };

      # 2. the consensus node (required for syncing to work)
      anytype-consensus = {
        image = "docker.io/anyproto/any-sync-consensusnode:latest";
        ports = [ "3000:3000" ];
        environment = {
          "any_sync_mongodb_connection" = "mongodb://anytype-mongo:27017";
          "any_sync_redis_connection" = "redis://anytype-redis:6379";
        };
      };

      anytype-mongo = {
        image = "docker.io/library/mongo:latest";
        volumes = [ "/var/lib/anytype/mongo:/data/db" ];
      };

      anytype-redis = {
        image = "docker.io/library/redis:alpine";
      };
    };

    networking.firewall.allowedtcpports = [ 33010 3000 ];
    networking.firewall.allowedudpports = [ 33020 ];
  };
}

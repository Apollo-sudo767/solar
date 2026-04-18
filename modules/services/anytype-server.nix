{ config, lib, ... }:

let
  cfg = config.myFeatures.services.anytype;
in
{
  options.myFeatures.services.anytype = {
    enable = lib.mkEnableOption "Anytype Self-Hosted Network";
    externalAddr = lib.mkOption {
      type = lib.types.str;
      default = "anytype.apollan.cc";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    
    virtualisation.oci-containers.containers = {
      anytype-sync = {
        image = "docker.io/anyproto/any-sync-node:latest";
        ports = [ "33010:33010" "33020:33020/udp" ];
        volumes = [ "/var/lib/anytype/storage:/etc/any-sync" ];
        environment = {
          "ANY_SYNC_MONGODB_CONNECTION" = "mongodb://anytype-mongo:27017";
          "ANY_SYNC_REDIS_CONNECTION" = "redis://anytype-redis:6379";
        };
        extraOptions = [ "--restart=always" ];
        dependsOn = [ "anytype-mongo" "anytype-redis" ];
      };

      anytype-consensus = {
        image = "docker.io/anyproto/any-sync-consensusnode:latest";
        ports = [ "3000:3000" ];
        environment = {
          "ANY_SYNC_MONGODB_CONNECTION" = "mongodb://anytype-mongo:27017";
          "ANY_SYNC_REDIS_CONNECTION" = "redis://anytype-redis:6379";
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

    # CAPITALIZED TCP/UDP
    networking.firewall.allowedTCPPorts = [ 33010 3000 ];
    networking.firewall.allowedUDPPorts = [ 33020 ];
  };
}

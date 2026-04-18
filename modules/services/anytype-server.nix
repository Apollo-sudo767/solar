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
        image = "docker.io/anyproto/any-sync-selfhosted:latest";
        ports = [
          "33010:33010"
          "33020:33020/udp"
        ];
        volumes = [
          "/var/lib/anytype/storage:/etc/any-sync"
        ];
        environment = {
          "ANY_SYNC_EXTERNAL_ADDR" = "${cfg.externalAddr}:33010";
          "ANY_SYNC_MONGODB_CONNECTION" = "mongodb://anytype-mongo:27017"; # FIXED PORT
          "ANY_SYNC_REDIS_CONNECTION" = "redis://anytype-redis:6379";
        };
        # Forces systemd to restart the container if it fails to connect to Mongo initially
        extraOptions = [ "--restart=always" ]; 
        dependsOn = [ "anytype-mongo" "anytype-redis" ];
      };

      anytype-mongo = {
        image = "docker.io/library/mongo:latest";
        volumes = [ "/var/lib/anytype/mongo:/data/db" ];
      };

      anytype-redis = {
        image = "docker.io/library/redis:alpine";
      };
    };

    networking.firewall.allowedTCPPorts = [ 33010 ];
    networking.firewall.allowedUDPPorts = [ 33020 ];
  };
}

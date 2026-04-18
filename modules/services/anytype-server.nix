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

    # We create a private network for the containers to talk to each other
    virtualisation.oci-containers.backend = "podman";
    
    virtualisation.oci-containers.containers = {
      # 1. The Sync Node (The Brain)
      anytype-sync = {
        image = "docker.io/anyproto/any-sync-selfhosted:latest";
        ports = [
          "33010:33010"     # TCP Sync
          "33020:33020/udp" # UDP QUIC
        ];
        volumes = [
          "/var/lib/anytype/storage:/etc/any-sync"
        ];
        environment = {
          "ANY_SYNC_EXTERNAL_ADDR" = "${cfg.externalAddr}:33010";
          "ANY_SYNC_MONGODB_CONNECTION" = "mongodb://anytype-mongo:27107";
          "ANY_SYNC_REDIS_CONNECTION" = "redis://anytype-redis:6379";
        };
        dependsOn = [ "anytype-mongo" "anytype-redis" ];
      };

      # 2. MongoDB (The Database)
      anytype-mongo = {
        image = "docker.io/library/mongo:latest";
        volumes = [ "/var/lib/anytype/mongo:/data/db" ];
      };

      # 3. Redis (The Cache)
      anytype-redis = {
        image = "docker.io/library/redis:alpine";
      };
    };

    # Open the "Front Door" in the NixOS Firewall
    networking.firewall.allowedTCPPorts = [ 33010 ];
    networking.firewall.allowedUDPPorts = [ 33020 ];
  };
}

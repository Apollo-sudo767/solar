{ config, lib, ... }:

let
  cfg = config.myFeatures.services.anytype;
in
{
  options.myFeatures.services.anytype = {
    enable = lib.mkEnableOption "Anytype Self-Hosted Sync Network";
    externalAddr = lib.mkOption {
      type = lib.types.str;
      example = "anytype.apollan.cc";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure Podman is enabled
    virtualisation.podman.enable = true;

    # Run Anytype as a container
    virtualisation.oci-containers.containers.anytype-server = {
      image = "anyproto/any-sync-bundle:latest";
      ports = [
        "33010:33010" # Yamux
        "33020:33020/udp" # QUIC
      ];
      volumes = [
        "/var/lib/anytype:/storage"
      ];
      environment = {
        "ANY_SYNC_BUNDLE_EXTERNAL_ADDR" = "${cfg.externalAddr}:33010";
      };
    };

    # Open the firewall
    networking.firewall.allowedTCPPorts = [ 33010 ];
    networking.firewall.allowedUDPPorts = [ 33020 ];
  };
}

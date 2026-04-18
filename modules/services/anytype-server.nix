{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.anytype;
in
{
  # --- OPTIONS ---
  options.myFeatures.services.anytype = {
    enable = lib.mkEnableOption "Anytype Self-Hosted Sync Node";

    # Port configuration with a default value
    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "The primary port for Anytype sync services.";
    };

    # Domain configuration for external access
    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "The external domain or IP address for the Anytype node.";
    };
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    # Open the configured port in the firewall
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    virtualisation.oci-containers.containers."anytype-sync" = {
      image = "grishagod/any-sync-bundle:latest";
      ports = [
        "${toString cfg.port}:${toString cfg.port}"
        "8001:8001"
        "8002:8002"
        "8003:8003"
      ];
      environment = {
        "EXTERNAL_ADDRESS" = cfg.domain; # Uses the domain defined in options
      };
      volumes = [
        "/var/lib/anytype:/app/storage"
      ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.networking.syncthing;
in
{
  options.myFeatures.services.networking.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Linux-specific Syncthing configuration
    (lib.mkIf (!isDarwin) {
      services.syncthing = {
        enable = true;
        user = "apollo";
        dataDir = "/home/apollo/Documents";
        configDir = "/home/apollo/.config/syncthing";
        
        # We'll let the user configure devices/folders manually or via a central config
        # For a truly automated setup, we'd need the device IDs.
        settings = {
          gui = {
            address = "127.0.0.1:8384"; # Only accessible via SSH tunnel or Tailscale
            user = "apollo";
            # NO PASSWORD HERE: Set it once in the Web UI. 
            # It will be saved to configDir and persist across rebuilds.
          };
        };
      };

      # Open ports for Syncthing (Sync only, not GUI)
      networking.firewall.allowedTCPPorts = [ 22000 ];
      networking.firewall.allowedUDPPorts = [ 22000 21027 ];
    })

    # Darwin-specific Syncthing configuration
    (lib.mkIf isDarwin {
      # On Darwin, we'll use Homebrew to manage the Syncthing service
      homebrew.services."syncthing" = "started";
      homebrew.brews = [ "syncthing" ];
    })
  ]);
}

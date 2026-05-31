{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.services.networking.syncthing;
  userCfg = config.myFeatures.core.system.users;
in
{
  options.myFeatures.services.networking.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Linux-specific Syncthing configuration
      (lib.optionalAttrs (!isDarwin) {
        services.syncthing = {
          enable = true;
          user = userCfg.mainUser;
          dataDir = "${userCfg.mainHome}/Documents";
          configDir = "${userCfg.mainHome}/.config/syncthing";

          # We'll let the user configure devices/folders manually or via a central config
          settings = {
            gui = {
              address = "127.0.0.1:8384"; # Only accessible via SSH tunnel or Tailscale
              user = userCfg.mainUser;
              # NO PASSWORD HERE: Set it once in the Web UI.
              # It will be saved to configDir and persist across rebuilds.
            };
          };
        };

        # Open ports for Syncthing (Sync only, not GUI)
        networking.firewall.allowedTCPPorts = [ 22000 ];
        networking.firewall.allowedUDPPorts = [
          22000
          21027
        ];
      })

      # Darwin-specific Syncthing configuration (using Homebrew)
      (lib.optionalAttrs isDarwin {
        homebrew.enable = true;
        homebrew.brews = [
          {
            name = "syncthing";
            start_service = true;
            restart_service = "changed";
          }
        ];
      })
    ]
  );
}

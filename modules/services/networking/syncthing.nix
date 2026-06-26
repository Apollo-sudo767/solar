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
          dataDir = "${userCfg.mainHome}/Documents/vault";
          configDir = "${userCfg.mainHome}/.config/syncthing";
          extraFlags = [ "--allow-newer-config" ];

          settings = {
            devices = {
              "venus" = {
                id = "3MHFG6M-DDG7OMR-PYTAMSQ-WSCFMAM-BR54N3O-36KAJVE-M22S5O7-ZHKZFQH";
                # Tell other machines to trust venus to introduce them to the rest of the fleet
                introducer = true;
              };
            };
            folders = {
              "Vault" = {
                path = "${userCfg.mainHome}/Documents/vault";
                # All machines share their Vault with venus by default
                devices = lib.optional (config.networking.hostName != "venus") "venus";
              };
            };
            gui = {
              address = "127.0.0.1:8384";
              user = userCfg.mainUser;
            };
          };
        };

        # Open ports for Syncthing (Sync only, not GUI)
        networking.firewall.allowedTCPPorts = [ 22000 ];
        networking.firewall.allowedUDPPorts = [
          22000
          21027
        ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [
                {
                  directory = "/home/${userCfg.mainUser}/.config/syncthing";
                  user = userCfg.mainUser;
                  group = "users";
                  mode = "0700";
                }
              ];
            };
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
        # Note: nix-darwin doesn't support declarative 'settings' for Homebrew-installed syncthing.
        # You will just need to add the Venus ID (3MHFG6M-...) once in the Mac Web UI (8384).
      })
    ]
  );
}

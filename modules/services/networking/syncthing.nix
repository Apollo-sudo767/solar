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
    introducer = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to configure an introducer device to automatically discover other fleet nodes.";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "sol";
        description = "Hostname of the fleet introducer node.";
      };
      id = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Syncthing Device ID of the introducer node.";
      };
    };
    devices = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Explicit Syncthing devices/peers.";
    };
    folders = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Additional or overridden Syncthing shared folders.";
    };
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
            devices = lib.mkMerge [
              cfg.devices
              (lib.optionalAttrs (cfg.introducer.enable && cfg.introducer.id != "" && config.networking.hostName != cfg.introducer.name) {
                "${cfg.introducer.name}" = {
                  inherit (cfg.introducer) id;
                  # Tell other machines to trust introducer to introduce them to the rest of the fleet
                  introducer = true;
                };
              })
            ];
            folders = lib.mkMerge [
              {
                "Vault" = {
                  path = "${userCfg.mainHome}/Documents/vault";
                  # Automatically sync Vault with introducer if configured
                  devices = lib.optional (cfg.introducer.enable && config.networking.hostName != cfg.introducer.name) cfg.introducer.name;
                };
              }
              cfg.folders
            ];
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

# modules/programs/utilities/filemanager/yazi.nix
#
# Configures the Yazi terminal file manager, optional default directory MIME
# associations, and state preservation on NixOS.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager.yazi;
in
{
  options.myFeatures.programs.utilities.filemanager.yazi = {
    enable = lib.mkEnableOption "Yazi Terminal File Manager";

    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Yazi as default application for directory and file browsing.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.yazi
    ];

    home-manager.sharedModules = [
      {
        home.sessionVariables = lib.mkIf cfg.default {
          FILEMANAGER = lib.mkDefault "yazi";
        };

        xdg.mimeApps = lib.mkIf cfg.default {
          enable = true;
          defaultApplications = {
            "inode/directory" = [ "yazi.desktop" ];
            "x-scheme-handler/file" = [ "yazi.desktop" ];
            "x-scheme-handler/trash" = [ "yazi.desktop" ];
          };
        };
      }
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/yazi"
            ];
          });
        };
  };
}

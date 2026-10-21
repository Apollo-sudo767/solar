# modules/programs/utilities/filemanager/nemo.nix
#
# Configures Cinnamon Nemo file manager with extensions, default directory
# MIME associations, and state preservation on NixOS.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager.nemo;
in
{
  options.myFeatures.programs.utilities.filemanager.nemo = {
    enable = lib.mkEnableOption "Cinnamon Nemo File Manager";

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Nemo as default application for directory and file browsing.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    environment.systemPackages = [
      pkgs.nemo-with-extensions
    ];

    home-manager.sharedModules = [
      {
        xdg.userDirs.enable = true;

        home.sessionVariables = lib.mkIf cfg.default {
          FILEMANAGER = lib.mkDefault "nemo";
        };

        xdg.mimeApps = lib.mkIf cfg.default {
          enable = true;
          defaultApplications = {
            "inode/directory" = [ "nemo.desktop" ];
            "x-scheme-handler/file" = [ "nemo.desktop" ];
            "x-scheme-handler/trash" = [ "nemo.desktop" ];
            "application/x-gnome-saved-search" = [ "nemo.desktop" ];
          };
        };
      }
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/nemo"
            ];
          });
        };
  };
}

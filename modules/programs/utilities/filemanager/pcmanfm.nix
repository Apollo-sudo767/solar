# modules/programs/utilities/filemanager/pcmanfm.nix
#
# Configures PCManFM lightweight GTK file manager, default directory MIME
# associations, and state preservation on NixOS.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager.pcmanfm;
in
{
  options.myFeatures.programs.utilities.filemanager.pcmanfm = {
    enable = lib.mkEnableOption "PCManFM File Manager";

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set PCManFM as default application for directory and file browsing.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    environment.systemPackages = [
      pkgs.pcmanfm
    ];

    home-manager.sharedModules = [
      {
        xdg.userDirs.enable = true;

        home.sessionVariables = lib.mkIf cfg.default {
          FILEMANAGER = lib.mkDefault "pcmanfm";
        };

        xdg.mimeApps = lib.mkIf cfg.default {
          enable = true;
          defaultApplications = {
            "inode/directory" = [ "pcmanfm.desktop" ];
            "x-scheme-handler/file" = [ "pcmanfm.desktop" ];
            "x-scheme-handler/trash" = [ "pcmanfm.desktop" ];
            "application/x-gnome-saved-search" = [ "pcmanfm.desktop" ];
          };
        };
      }
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/pcmanfm"
              ".local/share/file-manager"
            ];
          });
        };
  };
}

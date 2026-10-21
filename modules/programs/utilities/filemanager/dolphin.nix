# modules/programs/utilities/filemanager/dolphin.nix
#
# Configures KDE Dolphin file manager, thumbnailers, Ark archive manager,
# default directory MIME associations, and state preservation on NixOS.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager.dolphin;
in
{
  options.myFeatures.programs.utilities.filemanager.dolphin = {
    enable = lib.mkEnableOption "KDE Dolphin File Manager";

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Dolphin as default application for directory and file browsing.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    environment.systemPackages = with pkgs.kdePackages; [
      dolphin
      kdegraphics-thumbnailers
      ffmpegthumbs
      ark
    ];

    home-manager.sharedModules = [
      {
        xdg.userDirs.enable = true;

        home.sessionVariables = lib.mkIf cfg.default {
          FILEMANAGER = lib.mkDefault "dolphin";
        };

        xdg.mimeApps = lib.mkIf cfg.default {
          enable = true;
          defaultApplications = {
            "inode/directory" = [ "org.kde.dolphin.desktop" ];
            "x-scheme-handler/file" = [ "org.kde.dolphin.desktop" ];
            "x-scheme-handler/trash" = [ "org.kde.dolphin.desktop" ];
            "application/x-gnome-saved-search" = [ "org.kde.dolphin.desktop" ];
          };
        };
      }
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/dolphin"
              ".local/share/dolphin"
            ];
          });
        };
  };
}

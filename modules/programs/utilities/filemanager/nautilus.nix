{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager.nautilus;
in
{
  options.myFeatures.programs.utilities.filemanager.nautilus = {
    enable = lib.mkEnableOption "GNOME Nautilus File Manager";

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Nautilus as default application for directory and file browsing.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    environment.systemPackages = [
      pkgs.nautilus
      pkgs.file-roller
    ];

    home-manager.sharedModules = [
      {
        xdg.userDirs.enable = true;

        home.sessionVariables = lib.mkIf cfg.default {
          FILEMANAGER = lib.mkDefault "nautilus";
        };

        xdg.mimeApps = lib.mkIf cfg.default {
          enable = true;
          defaultApplications = {
            "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
            "x-scheme-handler/file" = [ "org.gnome.Nautilus.desktop" ];
            "x-scheme-handler/trash" = [ "org.gnome.Nautilus.desktop" ];
            "application/x-gnome-saved-search" = [ "org.gnome.Nautilus.desktop" ];
          };
        };
      }
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/nautilus"
            ];
          });
        };
  };
}

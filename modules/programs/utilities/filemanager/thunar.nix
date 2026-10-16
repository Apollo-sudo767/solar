{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager.thunar;
in
{
  options.myFeatures.programs.utilities.filemanager.thunar = {
    enable = lib.mkEnableOption "Thunar File Manager (XFCE)";

    enablePlugins = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Thunar plugins (tumbler thumbnailer, archive plugin, volman, media-tags).";
    };

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Thunar as default application for directory and file browsing.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    services.tumbler.enable = lib.mkDefault true;

    programs.thunar = {
      enable = true;
      plugins = lib.optionals cfg.enablePlugins (
        with pkgs;
        [
          thunar-archive-plugin
          thunar-volman
          thunar-media-tags-plugin
        ]
      );
    };

    environment.systemPackages = [
      pkgs.file-roller
    ];

    home-manager.sharedModules = [
      {
        xdg.userDirs.enable = true;

        home.sessionVariables = lib.mkIf cfg.default {
          FILEMANAGER = lib.mkDefault "thunar";
        };

        xdg.mimeApps = lib.mkIf cfg.default {
          enable = true;
          defaultApplications = {
            "inode/directory" = [ "thunar.desktop" ];
            "x-scheme-handler/file" = [ "thunar.desktop" ];
            "x-scheme-handler/trash" = [ "thunar.desktop" ];
            "application/x-gnome-saved-search" = [ "thunar.desktop" ];
          };
        };
      }
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/Thunar"
              ".config/xfce4/xfconf"
              ".local/share/Thunar"
            ];
          });
        };
  };
}

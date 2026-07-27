{
  config,
  lib,
  pkgs,
  isDarwin ? false,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager;

  activeManager =
    if cfg.thunar.enable then
      "thunar"
    else if cfg.nautilus.enable then
      "nautilus"
    else if cfg.dolphin.enable then
      "dolphin"
    else if cfg.yazi.enable then
      "yazi"
    else if cfg.nemo.enable then
      "nemo"
    else if cfg.pcmanfm.enable then
      "pcmanfm"
    else
      cfg.selection;

  managerConfig =
    {
      thunar = {
        binary = "thunar";
        desktop = "thunar.desktop";
      };
      nautilus = {
        binary = "nautilus";
        desktop = "org.gnome.Nautilus.desktop";
      };
      dolphin = {
        binary = "dolphin";
        desktop = "org.kde.dolphin.desktop";
      };
      yazi = {
        binary = "yazi";
        desktop = "yazi.desktop";
      };
      nemo = {
        binary = "nemo";
        desktop = "nemo.desktop";
      };
      pcmanfm = {
        binary = "pcmanfm";
        desktop = "pcmanfm.desktop";
      };
    }
    .${activeManager};

  desktopFile = managerConfig.desktop;
  binaryName = managerConfig.binary;
in
{
  options.myFeatures.programs.utilities.filemanager = {
    enable = lib.mkEnableOption "File Manager module";

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set the enabled file manager as the default application for directory and file browsing across all apps.";
    };

    selection = lib.mkOption {
      type = lib.types.enum [
        "thunar"
        "nautilus"
        "dolphin"
        "yazi"
        "nemo"
        "pcmanfm"
      ];
      default = "thunar";
      description = "Select the active file manager to install and set as default.";
    };

    thunar = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Thunar File Manager (XFCE).";
      };
      enablePlugins = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Thunar plugins (tumbler thumbnailer, archive plugin, volman, media-tags).";
      };
    };

    nautilus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable GNOME Nautilus File Manager.";
      };
    };

    dolphin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable KDE Dolphin File Manager.";
      };
    };

    yazi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Yazi TUI File Manager.";
      };
    };

    nemo = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Cinnamon Nemo File Manager.";
      };
    };

    pcmanfm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable PCManFM File Manager.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        # Common services for Linux file management
        services.gvfs.enable = true;
        services.udisks2.enable = true;

        # Manager-specific NixOS settings
        programs.thunar = lib.mkIf (activeManager == "thunar") {
          enable = true;
          plugins = lib.optionals cfg.thunar.enablePlugins (
            with pkgs;
            [
              thunar-archive-plugin
              thunar-volman
              thunar-media-tags-plugin
            ]
          );
        };

        services.tumbler.enable = lib.mkIf (activeManager == "thunar") true;

        environment.systemPackages =
          lib.optionals (activeManager == "thunar" || activeManager == "nautilus") [ pkgs.file-roller ]
          ++ lib.optionals (activeManager == "nautilus") [ pkgs.nautilus ]
          ++ lib.optionals (activeManager == "dolphin") (
            with pkgs.kdePackages;
            [
              dolphin
              kdegraphics-thumbnailers
              ffmpegthumbs
              ark
            ]
          )
          ++ lib.optionals (activeManager == "yazi") [ pkgs.yazi ]
          ++ lib.optionals (activeManager == "nemo") [ pkgs.nemo-with-extensions ]
          ++ lib.optionals (activeManager == "pcmanfm") [ pkgs.pcmanfm ];

        home-manager.sharedModules = [
          {
            xdg.userDirs.enable = true;

            home.sessionVariables = lib.mkIf cfg.default {
              FILEMANAGER = lib.mkDefault binaryName;
            };

            xdg.mimeApps = lib.mkIf cfg.default {
              enable = true;
              defaultApplications = {
                "inode/directory" = [ desktopFile ];
                "x-scheme-handler/file" = [ desktopFile ];
                "x-scheme-handler/trash" = [ desktopFile ];
                "application/x-gnome-saved-search" = [ desktopFile ];
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
                  ".config/nautilus"
                  ".config/dolphin"
                  ".config/yazi"
                  ".config/nemo"
                  ".config/pcmanfm"
                  ".local/share/file-manager"
                  ".local/share/Thunar"
                ];
              });
            };
      })
      (lib.optionalAttrs isDarwin {
        homebrew.casks = lib.optionals (
          config.myFeatures.darwin.system.homebrew.enable or false && activeManager == "commander-one"
        ) [ "commander-one" ];
      })
    ]
  );
}

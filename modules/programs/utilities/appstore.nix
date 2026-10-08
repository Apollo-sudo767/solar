{
  config,
  lib,
  pkgs,
  isDarwin ? false,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.appstore;

  desktops = config.myFeatures.platforms.desktops or { };

  isKdeOrQt = (desktops.kde.enable or false) || (desktops.lxqt.enable or false);

  isGnomeOrGtk =
    (desktops.gnome.enable or false)
    || (desktops.niri.enable or false)
    || (desktops.hyprland.enable or false)
    || (desktops.sway.enable or false)
    || (desktops.cinnamon.enable or false)
    || (desktops.mate.enable or false)
    || (desktops.xfce.enable or false)
    || (desktops.wayfire.enable or false)
    || (desktops.river.enable or false)
    || (desktops.mangowc.enable or false)
    || (desktops.labwc.enable or false)
    || (desktops.cosmic.enable or false)
    || (desktops.awesome.enable or false)
    || (desktops.bspwm.enable or false)
    || (desktops.i3.enable or false)
    || (desktops.qtile.enable or false)
    || (desktops.xmonad.enable or false)
    || (desktops.openbox.enable or false)
    || (desktops.budgie.enable or false)
    || (desktops.dwm.enable or false);

  enableGnomeSoftware =
    cfg.gnomeSoftware.enable
    || (cfg.selection == "gnome-software")
    || (cfg.selection == "both")
    || (cfg.selection == "auto" && (isGnomeOrGtk || !isKdeOrQt));

  enableDiscover =
    cfg.discover.enable
    || (cfg.selection == "discover")
    || (cfg.selection == "both")
    || (cfg.selection == "auto" && isKdeOrQt);
in
{
  options.myFeatures.programs.utilities.appstore = {
    enable = lib.mkEnableOption "Graphical software store & Flatpak installer (GNOME Software / KDE Discover)";

    selection = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "gnome-software"
        "discover"
        "both"
      ];
      default = "auto";
      description = "Which graphical software store/installer to use. 'auto' chooses Discover for KDE/Qt desktops, and GNOME Software for GNOME, Niri, and other GTK/Wayland environments.";
    };

    gnomeSoftware = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Explicitly enable GNOME Software (GTK4/Libadwaita Flatpak store).";
      };
    };

    discover = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Explicitly enable KDE Discover (Qt/Kirigami Flatpak store).";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        # Ensure Flatpak subsystem is active so the GUI stores can install and manage apps
        myFeatures.services.system.flatpak.enable = lib.mkDefault true;

        # GNOME Software configuration
        services.gnome.gnome-software.enable = lib.mkIf enableGnomeSoftware true;
        programs.dconf.enable = lib.mkIf enableGnomeSoftware (lib.mkDefault true);

        # KDE Discover configuration
        environment.systemPackages = lib.optionals enableDiscover [
          pkgs.kdePackages.discover
        ];

        # Preserved directories for app store metadata and caches on impermanent systems
        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories =
                  lib.optionals enableGnomeSoftware [
                    ".local/share/gnome-software"
                    ".cache/gnome-software"
                  ]
                  ++ lib.optionals enableDiscover [
                    ".local/share/discover"
                    ".cache/discover"
                  ];
              });
            };
      })
    ]
  );
}

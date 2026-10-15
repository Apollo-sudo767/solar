{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.matrix;

  desktops = config.myFeatures.platforms.desktops or { };
  desktopSuites = config.myFeatures.suites.desktops or { };

  # Window managers and desktop environments that are GDK/GTK-based
  isGdkBasedWm =
    (desktops.gnome.enable or false)
    || (desktopSuites.gnome.enable or false)
    || (desktops.niri.enable or false)
    || (desktopSuites.niri.enable or false)
    || (desktops.hyprland.enable or false)
    || (desktopSuites.hyprland.enable or false)
    || (desktops.sway.enable or false)
    || (desktopSuites.sway.enable or false)
    || (desktops.cinnamon.enable or false)
    || (desktopSuites.cinnamon.enable or false)
    || (desktops.mate.enable or false)
    || (desktopSuites.mate.enable or false)
    || (desktops.xfce.enable or false)
    || (desktopSuites.xfce.enable or false)
    || (desktops.budgie.enable or false)
    || (desktopSuites.budgie.enable or false)
    || (desktops.wayfire.enable or false)
    || (desktopSuites.wayfire.enable or false)
    || (desktops.river.enable or false)
    || (desktops.mangowc.enable or false)
    || (desktopSuites.mangowc.enable or false)
    || (desktops.labwc.enable or false)
    || (desktopSuites.labwc.enable or false)
    || (desktops.awesome.enable or false)
    || (desktopSuites.awesome.enable or false)
    || (desktops.bspwm.enable or false)
    || (desktopSuites.bspwm.enable or false)
    || (desktops.i3.enable or false)
    || (desktopSuites.i3.enable or false)
    || (desktops.qtile.enable or false)
    || (desktopSuites.qtile.enable or false)
    || (desktops.xmonad.enable or false)
    || (desktops.openbox.enable or false)
    || (desktopSuites.openbox.enable or false)
    || (desktops.dwm.enable or false);

  isKdeOrQt =
    (desktops.kde.enable or false)
    || (desktopSuites.plasma.enable or false)
    || (desktops.lxqt.enable or false)
    || (desktopSuites.lxqt.enable or false);

  selectedClient =
    if cfg.client != "auto" then
      cfg.client
    else if cfg.selection != "auto" then
      cfg.selection
    else if isGdkBasedWm && !isKdeOrQt then
      "fractal"
    else
      "element";

  enableFractal = cfg.fractal.enable || (selectedClient == "fractal") || (selectedClient == "both");

  enableElement = cfg.element.enable || (selectedClient == "element") || (selectedClient == "both");

  rawElementPkg =
    if cfg.element.package != pkgs.element-desktop then cfg.element.package else cfg.package;

  flags = [
    "--password-store=${cfg.passwordStore}"
  ]
  ++ cfg.extraCommandLineArgs;

  elementPkg =
    if pkgs.stdenv.hostPlatform.isLinux then
      (pkgs.symlinkJoin {
        name = "element-desktop";
        paths = [ rawElementPkg ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm $out/bin/element-desktop
          makeWrapper ${lib.getExe rawElementPkg} $out/bin/element-desktop \
            ${lib.concatMapStringsSep " " (flag: "--add-flags ${lib.escapeShellArg flag}") flags}
        '';
        meta = (rawElementPkg.meta or { }) // {
          mainProgram = "element-desktop";
        };
      })
    else
      rawElementPkg;
in
{
  options.myFeatures.programs.utilities.matrix = {
    enable = lib.mkEnableOption "Matrix messaging client (Fractal or Element Desktop)";

    client = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "fractal"
        "element"
        "both"
      ];
      default = "auto";
      description = "Which Matrix client to use ('auto', 'fractal', 'element', or 'both'). In 'auto' mode, Fractal is default for GDK-based window managers (GNOME, Budgie, Cinnamon, MATE, XFCE), and Element Desktop is used elsewhere.";
    };

    selection = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "fractal"
        "element"
        "both"
      ];
      default = "auto";
      description = "Alias for client selection.";
    };

    fractal = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Explicitly enable Fractal (GNOME/GTK4) Matrix client.";
      };

      package = lib.mkPackageOption pkgs "fractal" { };
    };

    element = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Explicitly enable Element Desktop Matrix client.";
      };

      package = lib.mkPackageOption pkgs "element-desktop" { };
    };

    # Backwards compatibility options for Element Desktop
    package = lib.mkPackageOption pkgs "element-desktop" { };

    passwordStore = lib.mkOption {
      type = lib.types.str;
      default = "gnome-libsecret";
      description = "Password store backend for Element Desktop (e.g. 'gnome-libsecret', 'basic', 'kwallet5').";
    };

    extraCommandLineArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command-line flags to pass to Element Desktop.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = lib.mkDefault (
      pkgs.stdenv.hostPlatform.isLinux
      && (enableFractal || (enableElement && cfg.passwordStore == "gnome-libsecret"))
    );

    programs.dconf.enable = lib.mkIf (enableFractal && pkgs.stdenv.hostPlatform.isLinux) (
      lib.mkDefault true
    );

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages =
        lib.optional enableElement elementPkg ++ lib.optional enableFractal cfg.fractal.package;
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories =
              lib.optionals enableElement [
                ".config/Element"
              ]
              ++ lib.optionals enableFractal [
                ".local/share/fractal"
              ];
          });
        };
  };
}

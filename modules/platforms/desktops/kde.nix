{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.kde;
in
{
  options.myFeatures.platforms.desktops.kde = {
    enable = lib.mkEnableOption "KDE Plasma 6 Desktop";
    karousel.enable = lib.mkEnableOption "Karousel scrollable-tiling KWin script";
    wallpaper = {
      stylix = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Set KDE Plasma desktop wallpaper to match Stylix theme image";
      };
    };
  };

  # Shield everything
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.xserver.enable = true;
        services.desktopManager.plasma6.enable = true;
        programs.kde-pim.enable = false;

        environment.variables = {
          QT_STYLE_OVERRIDE = lib.mkDefault "Breeze";
          KWIN_DRM_USE_MODIFIERS = "1";
          ENABLE_HDR_WSI = "1";
          DXVK_HDR = "1";
        };

        environment.systemPackages =
          with pkgs;
          [
            kdePackages.krunner
            kdePackages.plasma-nm
            kdePackages.plasma-pa
            kdePackages.dolphin
            kdePackages.spectacle
            kdePackages.ark
            kdePackages.konsole
            kdePackages.kate
            kdePackages.gwenview
            kdePackages.okular
            kdePackages.kcalc
            kdePackages.kdeconnect-kde
            kdePackages.kdegraphics-thumbnailers
            kdePackages.ffmpegthumbs
            kdePackages.qtstyleplugin-kvantum
            kdePackages.qqc2-desktop-style
            kdePackages.kirigami
            kdePackages.kirigami-addons
          ]
          ++ lib.optional cfg.karousel.enable pkgs.kdePackages.karousel;

        system.userActivationScripts = {
          enableKarousel = lib.mkIf cfg.karousel.enable {
            text = ''
              ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group Plugins --key karouselEnabled true
            '';
          };
        };

        services.displayManager.defaultSession = lib.mkDefault "plasma";

        home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          qt.enable = lib.mkForce false;
          stylix.targets.kde.enable = lib.mkForce true;

          xdg.configFile."kdeglobals".text = lib.mkIf config.stylix.enable (
            let
              hexToRgb =
                hex:
                let
                  r = builtins.fromTOML "x=0x${builtins.substring 0 2 hex}";
                  g = builtins.fromTOML "x=0x${builtins.substring 2 2 hex}";
                  b = builtins.fromTOML "x=0x${builtins.substring 4 2 hex}";
                in
                "${toString r.x},${toString g.x},${toString b.x}";
              bg = hexToRgb config.stylix.base16Scheme.base00;
              bgAlt = hexToRgb config.stylix.base16Scheme.base01;
              fg = hexToRgb config.stylix.base16Scheme.base05;
              accent = hexToRgb config.stylix.base16Scheme.base0D;
              selectionBg = hexToRgb config.stylix.base16Scheme.base0D;
              selectionFg = hexToRgb config.stylix.base16Scheme.base00;
            in
            lib.mkForce ''
              [General]
              ColorScheme=Stylix
              accentColor=${accent}

              [Colors:Window]
              BackgroundNormal=${bg}
              BackgroundAlternate=${bgAlt}
              ForegroundNormal=${fg}
              ForegroundActive=${accent}

              [Colors:View]
              BackgroundNormal=${bg}
              BackgroundAlternate=${bgAlt}
              ForegroundNormal=${fg}
              ForegroundActive=${accent}

              [Colors:Button]
              BackgroundNormal=${bgAlt}
              BackgroundAlternate=${bg}
              ForegroundNormal=${fg}
              ForegroundActive=${accent}

              [Colors:Header]
              BackgroundNormal=${bgAlt}
              BackgroundAlternate=${bg}
              ForegroundNormal=${fg}
              ForegroundActive=${accent}

              [Colors:Selection]
              BackgroundNormal=${selectionBg}
              BackgroundAlternate=${selectionBg}
              ForegroundNormal=${selectionFg}
              ForegroundActive=${selectionFg}

              [Colors:Tooltip]
              BackgroundNormal=${bgAlt}
              BackgroundAlternate=${bg}
              ForegroundNormal=${fg}
            ''
          );

          systemd.user.services.set-kde-theme = lib.mkIf (cfg.wallpaper.stylix && config.stylix.enable) {
            Unit = {
              Description = "Set KDE Plasma wallpaper and color scheme from Stylix";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage ${config.stylix.image} || true'";
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        });

        xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = lib.concatMap (name: [
                "/home/${name}/.config/kde.org"
                "/home/${name}/.local/share/kwalletd"
                "/home/${name}/.local/share/konsole"
                "/home/${name}/.local/share/dolphin"
                "/home/${name}/.local/share/kscreen"
              ]) config.myFeatures.core.system.users.usernames;
              files = lib.concatMap (name: [
                "/home/${name}/.config/kwinoutputconfig.json"
                "/home/${name}/.config/kwinrc"
              ]) config.myFeatures.core.system.users.usernames;
            };
      })
    ]
  );
}

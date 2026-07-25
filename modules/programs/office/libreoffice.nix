{
  config,
  lib,
  pkgs,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.libreoffice;
  loPkg =
    if pkgs.stdenv.isDarwin then
      pkgs.libreoffice-bin or pkgs.libreoffice
    else if cfg.variant == "fresh" then
      pkgs.libreoffice-fresh
    else
      pkgs.libreoffice-still;
in
{
  options.myFeatures.programs.office.libreoffice = {
    enable = lib.mkEnableOption "LibreOffice - The premiere open-source office productivity suite";

    variant = lib.mkOption {
      type = lib.types.enum [
        "fresh"
        "still"
      ];
      default = "fresh";
      description = "LibreOffice release branch: 'fresh' (latest features) or 'still' (stable enterprise).";
    };

    components = {
      writer = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "LibreOffice Writer word processor.";
      };
      calc = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "LibreOffice Calc spreadsheet processor.";
      };
      impress = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "LibreOffice Impress presentation tool.";
      };
      draw = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "LibreOffice Draw vector graphics editor.";
      };
      math = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "LibreOffice Math formula editor.";
      };
      base = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "LibreOffice Base database frontend.";
      };
    };

    spellcheck = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Hunspell spellcheckers and dictionaries (en_US, en_GB).";
    };

    enableOfficeFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install office-compatible fonts (Liberation, Carlito, Caladea, FreeFont).";
    };

    enableJava = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Java JRE support (required for LibreOffice Base relational database engine).";
    };

    iconTheme = lib.mkOption {
      type = lib.types.enum [
        "colibre"
        "breeze"
        "elementary"
        "sukapura"
        "karasa_jaga"
      ];
      default = "colibre";
      description = "Icon theme for LibreOffice toolbars.";
    };

    enableLanguageTool = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable LanguageTool grammar checker support.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      loPkg
    ]
    ++ lib.optionals cfg.spellcheck [
      pkgs.hunspell
      pkgs.hunspellDicts.en_US
      pkgs.hunspellDicts.en_GB-large
    ]
    ++ lib.optionals cfg.enableOfficeFonts [
      pkgs.liberation_ttf
      pkgs.carlito
      pkgs.caladea
      pkgs.freefont_ttf
    ]
    ++ lib.optional cfg.enableJava pkgs.jdk;

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xdg.mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
        enable = true;
        defaultApplications = {
          "application/vnd.oasis.opendocument.text" = lib.mkIf cfg.components.writer [
            "libreoffice-writer.desktop"
          ];
          "application/msword" = lib.mkIf cfg.components.writer [ "libreoffice-writer.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
            lib.mkIf cfg.components.writer
              [ "libreoffice-writer.desktop" ];

          "application/vnd.oasis.opendocument.spreadsheet" = lib.mkIf cfg.components.calc [
            "libreoffice-calc.desktop"
          ];
          "application/vnd.ms-excel" = lib.mkIf cfg.components.calc [ "libreoffice-calc.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = lib.mkIf cfg.components.calc [
            "libreoffice-calc.desktop"
          ];

          "application/vnd.oasis.opendocument.presentation" = lib.mkIf cfg.components.impress [
            "libreoffice-impress.desktop"
          ];
          "application/vnd.ms-powerpoint" = lib.mkIf cfg.components.impress [ "libreoffice-impress.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
            lib.mkIf cfg.components.impress
              [ "libreoffice-impress.desktop" ];
        };
      };

      home.sessionVariables = lib.mkIf (!pkgs.stdenv.isDarwin) {
        SAL_USE_VCLPLUGIN = if config.myFeatures.platforms.niri.enable or false then "gtk3" else "qt5";
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/libreoffice"
            ];
          });
        };
  };
}

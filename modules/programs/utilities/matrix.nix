# modules/programs/utilities/matrix.nix
#
# Configures Element Desktop Matrix client with custom keyring flags,
# declarative `config.json` pointing to `matrix.apollan.cc`, and state preservation.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.matrix;

  flags = [
    "--password-store=${cfg.passwordStore}"
  ]
  ++ cfg.extraCommandLineArgs;

  elementPkg =
    if pkgs.stdenv.hostPlatform.isLinux then
      (pkgs.symlinkJoin {
        name = "element-desktop";
        paths = [ cfg.package ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm $out/bin/element-desktop
          makeWrapper ${lib.getExe cfg.package} $out/bin/element-desktop \
            ${lib.concatMapStringsSep " " (flag: "--add-flags ${lib.escapeShellArg flag}") flags}
        '';
        meta = (cfg.package.meta or { }) // {
          mainProgram = "element-desktop";
        };
      })
    else
      cfg.package;
in
{
  options.myFeatures.programs.utilities.matrix = {
    enable = lib.mkEnableOption "Element-Desktop Matrix client";

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

    homeserverUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://matrix.apollan.cc";
      description = "Default Matrix homeserver URL for Element Desktop (hosted on Pluto cluster + UNAS Pro 4 NAS).";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "matrix.apollan.cc";
      description = "Default Matrix homeserver domain name.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = lib.mkDefault (
      pkgs.stdenv.hostPlatform.isLinux && cfg.passwordStore == "gnome-libsecret"
    );

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      home.packages = [
        elementPkg
      ];

      xdg.configFile."Element/config.json".text = builtins.toJSON {
        default_server_config = {
          "m.homeserver" = {
            base_url = cfg.homeserverUrl;
            server_name = cfg.serverName;
          };
        };
        brand = "Solar Matrix";
        disable_custom_urls = false;
        disable_guests = true;
        default_theme = "dark";
        room_directory = {
          servers = [
            cfg.serverName
            "matrix.org"
          ];
        };
        features = {
          feature_video_rooms = true;
          feature_group_calls = true;
          feature_element_call_video_rooms = true;
        };
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/Element"
            ];
          });
        };
  };
}

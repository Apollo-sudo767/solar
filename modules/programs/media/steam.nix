{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.steam;
in
{
  options.myFeatures.programs.media.steam = {
    enable = lib.mkEnableOption "Steam";

    protonInstaller = {
      enable = lib.mkEnableOption "GUI Proton installer (protonup-qt or protonup-gtk/protonplus)";
      flavor = lib.mkOption {
        type = lib.types.enum [
          "qt"
          "gtk"
          "auto"
        ];
        default = "auto";
        description = "Which flavor of GUI proton installer to use (Qt/protonup-qt or GTK/protonplus). 'auto' selects based on compositor.";
      };
    };

    gamescope = {
      enable = lib.mkEnableOption "Gamescope session / wrapper";
      capSysNice = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable CAP_SYS_NICE capability on gamescope wrapper (can cause bubblewrap/steam issues)";
      };
      autoWrap = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically launch Steam inside Gamescope when running under Wayland/Niri";
      };
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Arguments to pass to Gamescope";
      };
      env = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Environment variables for Gamescope";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package =
        let
          makeWrappedSteam =
            steamPkg:
            (pkgs.symlinkJoin {
              name = "steam-wrapped";
              paths = [ steamPkg ];
              postBuild = ''
                rm $out/bin/steam
                cat <<'EOF' > $out/bin/steam
                #!/bin/sh
                ${lib.optionalString (cfg.gamescope.enable && cfg.gamescope.autoWrap) ''
                  if [ "$XDG_CURRENT_DESKTOP" = "niri" ] || [ -n "$NIRI_SOCKET" ]; then
                    if [ "$STEAM_GAMESCOPE_WRAPPED" != "1" ] && command -v steam-gamescope >/dev/null 2>&1; then
                      export STEAM_GAMESCOPE_WRAPPED=1
                      exec steam-gamescope "$@"
                    fi
                  fi
                ''}
                exec ${steamPkg}/bin/steam "$@"
                EOF
                chmod +x $out/bin/steam
              '';
            })
            // {
              inherit (steamPkg) run;
            };
          initialSteam = pkgs.steam.override {
            extraArgs = "-cef-disable-gpu-compositing";
          };
          wrapped = makeWrappedSteam initialSteam;
        in
        wrapped
        // {
          override = f: makeWrappedSteam (initialSteam.override f);
        };
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true; # Useful if you host local test servers
      gamescopeSession = {
        enable = cfg.gamescope.enable;
        args = cfg.gamescope.args;
        env = cfg.gamescope.env;
      };
    };

    programs.gamescope = {
      enable = cfg.gamescope.enable;
      capSysNice = cfg.gamescope.capSysNice;
    };

    programs.gamemode.enable = true;

    environment.systemPackages =
      let
        useGtk =
          if cfg.protonInstaller.flavor == "auto" then
            !(config.myFeatures.platforms.desktops.kde.enable or false)
          else
            cfg.protonInstaller.flavor == "gtk";
        protonPackage = if useGtk then pkgs.protonplus else pkgs.protonup-qt;
      in
      with pkgs;
      [
        mangohud
        gamemode
        libkrb5
        keyutils
      ]
      ++ lib.optional cfg.protonInstaller.enable protonPackage
      ++ lib.optional cfg.gamescope.enable (
        pkgs.makeDesktopItem {
          name = "steam-gamescope";
          desktopName = "Steam (Gamescope)";
          genericName = "Game 3D Engine";
          comment = "Launch Steam inside Gamescope micro-compositor";
          exec = "steam-gamescope";
          icon = "steam";
          terminal = false;
          type = "Application";
          categories = [
            "Network"
            "FileTransfer"
            "Game"
          ];
        }
      );

    preservation.preserveAt =
      let
        pCfg = config.myFeatures.core.system.preservation;
        users = config.myFeatures.core.system.users.usernames;
        steamDirs = [
          ".local/share/Steam"
          ".steam" # Steam registry and config
        ]
        ++ lib.optionals cfg.protonInstaller.enable [
          ".config/pupgui"
          ".config/protonplus"
        ];
        bulkDirs = [
          {
            directory = ".local/share/SteamBulk";
            mode = "0700";
          }
        ];
      in
      lib.mkIf pCfg.enable (
        if pCfg.coldPath == pCfg.persistentPath then
          {
            "${pCfg.persistentPath}".users = lib.genAttrs users (name: {
              directories = steamDirs ++ bulkDirs;
            });
          }
        else
          {
            "${pCfg.persistentPath}".users = lib.genAttrs users (name: {
              directories = steamDirs;
            });
            "${pCfg.coldPath}".users = lib.genAttrs users (name: {
              directories = bulkDirs;
            });
          }
      );

    # Ensure the directory exists with correct ownership on the bulk drive
    systemd.tmpfiles.rules = lib.concatMap (name: [
      "d /home/${name}/.local/share/SteamBulk 0700 ${name} users - -"
    ]) config.myFeatures.core.system.users.usernames;

    # Automatically sync Steam desktop entries from ~/Desktop to ~/.local/share/applications
    systemd.user.paths.steam-desktop-sync = {
      description = "Watch Desktop for Steam shortcuts";
      wantedBy = [ "default.target" ];
      pathConfig = {
        PathChanged = "%h/Desktop";
      };
    };

    systemd.user.services.steam-desktop-sync = {
      description = "Sync Steam shortcuts from Desktop to applications folder";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "steam-desktop-sync-exec" ''
          mkdir -p "$HOME/.local/share/applications"
          find "$HOME/.local/share/applications" -xtype l -delete
          for f in "$HOME"/Desktop/*.desktop; do
            [ -e "$f" ] || continue
            if grep -q "steam://rungameid/" "$f"; then
              ln -sf "$f" "$HOME/.local/share/applications/$(basename "$f")"
            fi
          done
        '';
      };
    };

    environment.sessionVariables = {
      SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      xdg.desktopEntries = lib.mkIf cfg.gamescope.enable (
        let
          argsString = lib.escapeShellArgs cfg.gamescope.args;
          envList = lib.mapAttrsToList (name: value: "${name}=${lib.escapeShellArg value}") cfg.gamescope.env;
          envPrefix = lib.concatStringsSep " " envList;
          gamescopeArgs = lib.concatStringsSep " " (
            lib.filter (s: s != "") [
              "--steam"
              argsString
            ]
          );
          gamescopeCmd = "${
            if envPrefix != "" then envPrefix + " " else ""
          }gamescope ${gamescopeArgs} -- steam";

          steam-launcher = pkgs.writeShellScriptBin "steam-launcher" ''
            ${
              if cfg.gamescope.autoWrap then
                ''
                  if [ -n "$WAYLAND_DISPLAY" ] && [ -z "$GAMESCOPE_WAYLAND_DISPLAY" ] && [ -z "$INSIDE_GAMESCOPE" ]; then
                    export INSIDE_GAMESCOPE=1
                    exec ${gamescopeCmd} "$@"
                  else
                    exec steam "$@"
                  fi
                ''
              else
                ''
                  exec steam "$@"
                ''
            }
          '';
        in
        {
          steam = {
            name = "Steam";
            genericName = "Game Client";
            comment = "Application for managing and playing games on Steam";
            exec = "${steam-launcher}/bin/steam-launcher %U";
            icon = "steam";
            terminal = false;
            type = "Application";
            categories = [
              "Network"
              "FileTransfer"
              "Game"
            ];
            mimeType = [
              "x-scheme-handler/steam"
              "x-scheme-handler/steamlink"
            ];
            settings = {
              PrefersNonDefaultGPU = "true";
              X-KDE-RunOnDiscreteGpu = "true";
            };
            actions = {
              Store = {
                name = "Store";
                exec = "${steam-launcher}/bin/steam-launcher steam://store";
              };
              Community = {
                name = "Community";
                exec = "${steam-launcher}/bin/steam-launcher steam://url/CommunityHome/";
              };
              Library = {
                name = "Library";
                exec = "${steam-launcher}/bin/steam-launcher steam://open/games";
              };
              Servers = {
                name = "Servers";
                exec = "${steam-launcher}/bin/steam-launcher steam://open/servers";
              };
              Screenshots = {
                name = "Screenshots";
                exec = "${steam-launcher}/bin/steam-launcher steam://open/screenshots";
              };
              News = {
                name = "News";
                exec = "${steam-launcher}/bin/steam-launcher steam://openurl/https://store.steampowered.com/news";
              };
              Settings = {
                name = "Settings";
                exec = "${steam-launcher}/bin/steam-launcher steam://open/settings";
              };
              BigPicture = {
                name = "Big Picture";
                exec = "${steam-launcher}/bin/steam-launcher steam://open/bigpicture";
              };
              Friends = {
                name = "Friends";
                exec = "${steam-launcher}/bin/steam-launcher steam://open/friends";
              };
            };
          };
        }
      );
    });
  };
}

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
      package = let
        makeWrappedSteam = steamPkg: (pkgs.symlinkJoin {
          name = "steam-wrapped";
          paths = [ steamPkg ];
          postBuild = ''
            rm $out/bin/steam
            cat <<'EOF' > $out/bin/steam
            #!/bin/sh
            if [ "$XDG_CURRENT_DESKTOP" = "niri" ] || [ -n "$NIRI_SOCKET" ]; then
              if [ "$STEAM_GAMESCOPE_WRAPPED" != "1" ] && command -v steam-gamescope >/dev/null 2>&1; then
                export STEAM_GAMESCOPE_WRAPPED=1
                exec steam-gamescope "$@"
              fi
            fi
            exec ${steamPkg}/bin/steam "$@"
            EOF
            chmod +x $out/bin/steam
          '';
        }) // {
          inherit (steamPkg) run;
        };
        initialSteam = pkgs.steam.override {
          extraArgs = "-cef-disable-gpu-compositing";
        };
        wrapped = makeWrappedSteam initialSteam;
      in wrapped // {
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
      capSysNice = cfg.gamescope.enable;
    };

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
  };
}

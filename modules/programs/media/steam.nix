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
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true; # Useful if you host local test servers
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
      ++ lib.optional cfg.protonInstaller.enable protonPackage;

    preservation.preserveAt =
      let
        pCfg = config.myFeatures.core.system.preservation;
        users = config.myFeatures.core.system.users.usernames;
      in
      lib.mkIf pCfg.enable (
        lib.recursiveUpdate
          {
            "${pCfg.persistentPath}".users = lib.genAttrs users (name: {
              directories = [
                ".local/share/Steam"
                ".steam" # Steam registry and config
              ]
              ++ lib.optionals cfg.protonInstaller.enable [
                ".config/pupgui"
                ".config/protonplus"
              ];
            });
          }
          {
            "${pCfg.coldPath}".users = lib.genAttrs users (name: {
              directories = [
                {
                  directory = ".local/share/SteamBulk";
                  mode = "0700";
                }
              ];
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

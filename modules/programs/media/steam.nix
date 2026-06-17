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
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true; # Useful if you host local test servers
    };

    environment.systemPackages = with pkgs; [
      mangohud
      gamemode
      libkrb5
      keyutils
    ];

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
                ".local/share/applications" # Steam game shortcuts
                ".local/share/icons" # Steam game icons
                ".steam" # Steam registry and config
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
  };
}

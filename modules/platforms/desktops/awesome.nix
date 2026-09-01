{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.awesome;
in
{
  options.myFeatures.platforms.desktops.awesome = {
    enable = lib.mkEnableOption "AwesomeWM (Lua-programmable Dynamic X11 Tiling Window Manager)";

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra Lua code appended to rc.lua";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [
          luarocks
          luafilesystem
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      dmenu
      feh
      picom
      xclip
      libnotify
      brightnessctl
    ];

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xsession.windowManager.awesome = {
        enable = true;
        extraConfig = lib.concatStringsSep "\n" cfg.extraConfig;
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/awesome"
            ];
          });
        };
  };
}

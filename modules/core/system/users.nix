{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  inherit isDarwin isTotal;
  cfg = config.myFeatures.core.system.users;
in
{
  options.myFeatures.core.system.users = {
    enable = lib.mkEnableOption "User Management";
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "apollo" ];
      description = "List of users to configure.";
    };
    mainUser = lib.mkOption {
      type = lib.types.str;
      default = lib.head cfg.usernames;
      description = "The primary user of the system.";
    };
    mainHome = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = config.users.users.${cfg.mainUser}.home;
      description = "The home directory of the primary user.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Cross-Platform User Definitions
    users.users = lib.genAttrs cfg.usernames (
      name:
      {
        # Home directory path varies by OS
        home = if isDarwin then "/Users/${name}" else "/home/${name}";

        # Ensure shells are available
        shell = pkgs.zsh;
      }
      // lib.optionalAttrs (!isDarwin) {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
        ];
        initialPassword = "solar";
      }
    );

    # 2. Home Manager Default Settings for all users
    home-manager.users = lib.genAttrs cfg.usernames (name: {
      home.stateVersion = "26.11";
      home.username = name;
      home.homeDirectory = config.users.users.${name}.home;
    });
  };
}


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
      default = if lib.elem "apollo" cfg.usernames then "apollo" else lib.head cfg.usernames;
      description = "The primary user of the system.";
    };
    mainHome = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = config.users.users.${cfg.mainUser}.home;
      description = "The home directory of the primary user.";
    };
    agenixPassword = lib.mkEnableOption "agenix-managed passwords for users";
  };

  config = lib.mkIf cfg.enable {
    # Disable mutable users if agenixPassword is enabled to ensure strict management
    users.mutableUsers = lib.mkDefault (!cfg.agenixPassword);

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
        # Password Logic:
        # 1. Priority: Host-specific > User-specific > Global Fallback
        # 2. If agenixPassword is disabled, use initialPassword "solar"
        hashedPasswordFile = lib.mkIf cfg.agenixPassword (
          let
            hostSecret = "password-${config.networking.hostName}.age";
            userSecret = "password-${name}.age";
            fallback = "password-apollo.age";
          in
          if (config.age.secrets ? ${hostSecret}) then
            config.age.secrets.${hostSecret}.path
          else if (config.age.secrets ? ${userSecret}) then
            config.age.secrets.${userSecret}.path
          else if (config.age.secrets ? ${fallback}) then
            config.age.secrets.${fallback}.path
          else
            null
        );

        initialPassword = lib.mkIf (
          !cfg.agenixPassword || config.users.users.${name}.hashedPasswordFile == null
        ) "solar";
      }
    );

    # 2. Home Manager Default Settings for all users
    home-manager.users = lib.genAttrs cfg.usernames (name: {
      home.stateVersion = "26.11";
      home.username = name;
      home.homeDirectory = config.users.users.${name}.home;
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !isDarwin)
        {
          directories = lib.concatMap (name: [
            "/home/${name}/Documents"
            "/home/${name}/Downloads"
            "/home/${name}/Pictures"
            "/home/${name}/Videos"
            "/home/${name}/Desktop"
            "/home/${name}/src"
            "/home/${name}/.local/share/keyrings"
            "/home/${name}/.local/state" # Critical for wireplumber, etc.
            "/home/${name}/.cache/nix" # Cache nix evaluations
            "/home/${name}/.cache/fontconfig" # Avoid regenerating fonts
          ]) cfg.usernames;
        };
  };
}

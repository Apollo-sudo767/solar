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
        # 1. Use password-<username>.age if it exists
        # 2. Otherwise, fall back to password-apollo.age
        # 3. If neither exists and agenixPassword is off, use "solar"
        hashedPasswordFile = lib.mkIf cfg.agenixPassword (
          if (config.age.secrets ? "password-${name}.age") then
            config.age.secrets."password-${name}.age".path
          else if (config.age.secrets ? "password-apollo.age") then
            config.age.secrets."password-apollo.age".path
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

    # 3. Innate Ownership Management (systemd-tmpfiles)
    # Using 'Z' (recursive) instead of 'd' ensures that the entire directory
    # tree is owned by the user, fixing issues with Firefox and other apps.
    systemd.tmpfiles.rules = lib.concatMap (name: [
      "Z /home/${name} 0700 ${name} users - -"
      "Z /persist/home/${name} 0700 ${name} users - -"
    ]) cfg.usernames;

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !isDarwin)
        {
          users = lib.genAttrs cfg.usernames (name: {
            directories = [
              "Documents"
              "Downloads"
              "Pictures"
              "Videos"
              "Desktop"
              "src"
              ".local/share/keyrings"
              ".local/share/direnv"
              ".local/share/niri" # Niri state
              ".local/share/noctalia" # Noctalia state
              ".local/state" # Critical for wireplumber, etc.
              ".cache/nix" # Cache nix evaluations
              ".cache/fontconfig" # Avoid regenerating fonts
              ".cache/noctalia" # Noctalia cache
              ".ssh" # User SSH keys
              ".gnupg" # GPG keys
              ".pki" # PKI certificates
            ];
          });
        };
  };
}

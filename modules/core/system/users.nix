{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal,
  isStable ? false,
  ...
}:

let
  inherit isDarwin isTotal;
  cfg = config.myFeatures.core.system.users;
  hasPrivateSecrets =
    (builtins.hasAttr "solar-secrets" inputs)
    && (inputs.solar-secrets ? outPath)
    && (builtins.pathExists "${inputs.solar-secrets}/secrets");
  useAgenixPassword =
    cfg.agenixPassword && (config.myFeatures.core.security.agenix.enable or false) && hasPrivateSecrets;
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

  config = lib.mkMerge [
    # 1. Universal Configuration (Evaluated if feature is enabled, cross-platform)
    (lib.mkIf cfg.enable {
      # Cross-Platform User Definitions
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
          # Password Logic
          hashedPasswordFile =
            if useAgenixPassword then
              (
                if (config.age.secrets ? "password-${name}.age") then
                  config.age.secrets."password-${name}.age".path
                else if (config.age.secrets ? "password-apollo.age") then
                  config.age.secrets."password-apollo.age".path
                else
                  null
              )
            else
              "/etc/user-password";
        }
      );

      # Home Manager Default Settings for all users
      home-manager.backupFileExtension = "backup";
      home-manager.users = lib.genAttrs cfg.usernames (name: {
        home.stateVersion =
          if isDarwin then
            (if isStable then "26.05" else "26.11")
          else
            (config.system.stateVersion or "26.11");
        home.username = name;
        home.homeDirectory = config.users.users.${name}.home;
      });
    })

    # 2. Linux-only Configuration (Completely omitted from evaluation on Darwin)
    (lib.mkIf cfg.enable (
      lib.optionalAttrs (!isDarwin) {
        # Initialize default user password if it doesn't exist
        system.activationScripts.user-password-init = {
          text = ''
            if [ ! -f /etc/user-password ]; then
              mkdir -p /etc
              echo '$6$/Edi4zjoQYa81MQL$MD/BacUUKnb3jdHCnAzRG5s2Vh7KUIYh4s0h/5SQzMLVpbJ7T6XKCvYMuMZ2Sqt91quxmHATBEzkuyQKzQ/K5/' > /etc/user-password
              chmod 600 /etc/user-password
            fi
          '';
        };

        # Moved here because nix-darwin doesn't support changing account mutability
        users.mutableUsers = lib.mkDefault (!useAgenixPassword);

        # Using 'Z' (recursive) instead of 'd' ensures that the entire directory
        # tree is owned by the user, fixing issues with Firefox and other apps.
        systemd.tmpfiles.rules = lib.concatMap (name: [
          "Z /home/${name} 0700 ${name} users - -"
          "Z /persist/home/${name} 0700 ${name} users - -"
        ]) cfg.usernames;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
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
                  ".local/share/applications"
                  ".local/share/noctalia"
                  ".local/state"
                  ".cache/nix"
                  ".cache/fontconfig"
                  ".cache/noctalia"
                  ".ssh"
                  ".gnupg"
                  ".pki"
                ];
              });
            };

        virtualisation.vmVariant = {
          virtualisation.memorySize = 4096;
          virtualisation.cores = 4;
          virtualisation.forwardPorts = [
            {
              from = "host";
              host.port = 2222;
              guest.port = 22;
            }
          ];
          virtualisation.qemu.options = [
            "-vga"
            "std"
          ];
          services.openssh = {
            enable = true;
            settings.PermitRootLogin = lib.mkForce "yes";
            settings.PermitEmptyPasswords = lib.mkForce "yes";
          };
          environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";
          age.secrets = lib.mkForce { };
          services.displayManager.defaultSession = lib.mkForce "plasma";
          services.displayManager.autoLogin = {
            enable = true;
            user = cfg.mainUser;
          };
          users.users =
            (lib.genAttrs cfg.usernames (name: {
              hashedPasswordFile = lib.mkForce null;
              hashedPassword = lib.mkForce null;
              password = lib.mkForce "nixos";
            }))
            // {
              root = {
                password = "nixos";
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcokRBeRaSFM1qXB+Qs+A74BkdNmfuxcN5PSKIsBfli apollo@mars"
                ];
              };
            };
        };
      }
    ))
  ];
}

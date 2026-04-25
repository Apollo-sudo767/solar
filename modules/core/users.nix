{ config, lib, pkgs, inputs, isStable ? true, isDarwin, ... }:

let
  cfg = config.myFeatures.core.users;
  
  # Standardize on your new version targets
  dynamicVersion = if isStable then "25.11" else "26.05";
in
{
  options.myFeatures.core.users = {
    enable = lib.mkEnableOption "Standard User Configuration";
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "apollo" ];
      description = "List of users to initialize on this host";
    };
  };

  config = lib.mkIf cfg.enable {
    _module.args.usernames = cfg.usernames;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = { inherit inputs; };

      users = lib.genAttrs cfg.usernames (name: {
        home.stateVersion = dynamicVersion;
      });
    };

    # System-level user definitions
    users.users = lib.genAttrs cfg.usernames (name: 
      lib.mkMerge [
        # 1. Attributes safe for BOTH macOS and Linux
        {
          shell = pkgs.zsh;
          home = if isDarwin then "/Users/${name}" else "/home/${name}";
        }

        # 2. Attributes ONLY for Linux (Physically removed on Mac)
        (lib.optionalAttrs (!isDarwin) {
          isNormalUser = true;
          extraGroups = [ 
            "wheel" 
            "networkmanager" 
            "video" 
            "audio" 
            "docker" 
            "lp" 
          ];
        })
      ]
    );
  };
}

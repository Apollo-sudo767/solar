{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.users;
in
{
  options.myFeatures.core.users = {
    enable = lib.mkEnableOption "Standard User Configuration";
    
    # This allows you to define users per-host without editing this file
    usernames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "apollo" ]; 
      description = "List of users to create and make trusted.";
    };
  };

  config = lib.mkIf cfg.enable {
    # --- NIX DAEMON SETTINGS ---
    # This makes every user in the list 'trusted', allowing them to 
    # use binary caches and manage the nix store without constant sudo.
    nix.settings.trusted-users = [ "root" ] ++ cfg.usernames;

    # --- USER DEFINITIONS ---
    # We loop through the list of usernames and apply your Phanes settings to each.
    users.users = lib.genAttrs cfg.usernames (name: {
      isNormalUser = true;
      extraGroups = [ 
        "wheel"           # Sudo access
        "networkmanager"  # Wi-Fi control
        "video"           # GPU access
        "audio"           # Sound control
        "docker"          # From your Phanes server.nix
        "lp"              # Printing
      ];
      # Ensures they start with Zsh (from your shell.nix)
      shell = pkgs.zsh;
    });
  };
}

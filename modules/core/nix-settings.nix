{ config, lib, pkgs, isDarwin, ... }:

{
  options.myFeatures.core.nix-settings.enable = lib.mkEnableOption "Core Nix flake and optimization settings";

  config = lib.mkIf config.myFeatures.core.nix-settings.enable {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        warn-dirty = false;
        substituters = [ "https://niri.cachix.org" ];
        trusted-public-keys = [ "niri.cachix.org-1:Wv0Om607Z5KVzEDGyz69m0shV6vba6Kndf6966fS38Y=" ];
      };
      
      # Automatic Garbage Collection
      gc = lib.mkMerge [
        {
          automatic = true;
          options = "--delete-older-than 7d";
        }
        # Linux-specific settings
        (lib.optionalAttrs (!isDarwin) {
          dates = "weekly";
        })
        # Darwin-specific settings
        (lib.optionalAttrs isDarwin {
          interval = { Weekday = 0; Hour = 0; Minute = 0; }; 
        })
      ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
  };
}

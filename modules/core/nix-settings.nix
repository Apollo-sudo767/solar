{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

{
  options.myFeatures.core.nix-settings.enable =
    lib.mkEnableOption "Core Nix flake and optimization settings";

  config = lib.mkIf config.myFeatures.core.nix-settings.enable {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        warn-dirty = false;
        substituters = [ "https://niri.cachix.org" ];
        trusted-public-keys = [ "niri.cachix.org-1:Wv0Om607Z5KVzEDGyz69m0shV6vba6Kndf6966fS38Y=" ];
      };

      # FIX: Only enable Nix-managed GC on Linux using the built-in stdenv check.
      gc = lib.mkIf pkgs.stdenv.isLinux {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
  };
}

{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  inherit isTotal;
  cfg = config.myFeatures.core.nix.nix-settings;
in
{
  options.myFeatures.core.nix.nix-settings.enable =
    lib.mkEnableOption "Core Nix flake and optimization settings";

  config = lib.mkIf cfg.enable {
    nix = {
      channel.enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux false;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        warn-dirty = false;
      };

      # FIX: Only enable Nix-managed GC on Linux using the built-in stdenv check.
      gc = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    # Allow unfree packages
    nixpkgs.config = {
      allowUnfree = true;
    };
    nixpkgs.overlays = [
      (final: prev: {
        yt-dlp = prev.yt-dlp.override { javascriptSupport = false; };
      })
    ];
  };
}

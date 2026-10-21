# modules/core/nix/nix-settings.nix
# ============================================================================
# Core Nix Daemon, Store Optimization & Garbage Collection Settings
# ============================================================================
# Configures Flakes (`nix-command`, `flakes`), store hardlink deduplication,
# automatic free-space watermark garbage collection, and weekly scheduled GC
# on Linux hosts. (Note: `nixpkgs.config.allowUnfree = lib.mkDefault true;` is
# configured globally in `modules/hosts/default.nix`.)
{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.nix.nix-settings;
in
{
  options.myFeatures.core.nix.nix-settings.enable =
    lib.mkEnableOption "Core Nix flake and optimization settings";

  config = lib.mkIf (cfg.enable && isTotal) {
    nix = {
      # Disable legacy nix-channel commands on Linux in favor of pure Flakes
      channel.enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux false;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        warn-dirty = false;
        min-free = 10 * 1024 * 1024 * 1024; # Trigger auto-GC when free space drops below 10 GiB
        max-free = 25 * 1024 * 1024 * 1024; # Free up to 25 GiB when auto-GC runs
      };

      # Canonical weekly garbage collection schedule for Linux hosts
      # (Skipped on macOS where Determinate Nix manages the store daemon)
      gc = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        options = lib.mkDefault "--delete-older-than 7d";
      };
    };

    nixpkgs.overlays = [
      (_final: prev: {
        yt-dlp = prev.yt-dlp.override { javascriptSupport = false; };
      })
    ];
  };
}

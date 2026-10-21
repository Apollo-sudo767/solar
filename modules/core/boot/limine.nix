# modules/core/boot/limine.nix
# ============================================================================
# Limine UEFI Bootloader (`myFeatures.core.boot.loader = "limine"`)
# ============================================================================
# Default UEFI bootloader for Solar Linux hosts. Applies custom wallpaper
# styling from `assets/wallpapers/limine-bg.png` and optional GOP display
# resolution (`myFeatures.core.boot.resolution`).
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
  wallpaperPath = ../../../assets/wallpapers/limine-bg.png;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "limine") {
    # Disable systemd-boot when Limine is active
    boot.loader.systemd-boot.enable = false;

    boot.loader.limine = {
      enable = true;

      style = {
        wallpapers = lib.mkForce [ wallpaperPath ];
        wallpaperStyle = "stretched";
      };
    }
    // lib.optionalAttrs (cfg.resolution != null) {
      inherit (cfg) resolution;
    };

    environment.systemPackages = with pkgs; [
      limine
      efibootmgr
    ];
  };
}

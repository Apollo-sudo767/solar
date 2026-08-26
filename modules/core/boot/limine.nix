{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
  # Points to your assets folder relative to this file
  wallpaperPath = ../../../assets/wallpapers/limine-bg.png;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "limine") (
    lib.optionalAttrs (!isDarwin) {
      # Disable the default systemd-boot to make room for Limine
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
    }
  );
}

# modules/core/system/localeChicago.nix
# ============================================================================
# System Timezone & Locale (`America/Chicago` / `en_US.UTF-8`)
# ============================================================================
# Sets the system timezone across Linux and macOS, and configures UTF-8 locale
# settings on Linux. Enabled by default via `myFeatures.core.system.core-branch`.
{
  config,
  lib,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.system.localeChicago;
in
{
  options.myFeatures.core.system.localeChicago = {
    enable = lib.mkEnableOption "Chicago Locale/Timezone";
  };

  config = lib.mkIf (cfg.enable && isTotal) (
    lib.mkMerge [
      # 1. Cross-Platform Timezone (Linux & macOS)
      {
        time.timeZone = "America/Chicago";
      }

      # 2. Linux-Only glibc Locale Settings
      (lib.optionalAttrs (!isDarwin) {
        i18n.defaultLocale = "en_US.UTF-8";
      })
    ]
  );
}

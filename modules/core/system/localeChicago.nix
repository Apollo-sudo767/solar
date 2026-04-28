{
  lib,
  isDarwin,
  isTotal,
  ...
}:

{
  options.myFeatures.core.system.localeChicago = {
    enable = lib.mkEnableOption "Chicago Locale/Timezone";
  };

  config = lib.mkIf isTotal (
    lib.mkMerge [
      # 1. Common configuration for both Mac and Linux
      {
        time.timeZone = "America/Chicago";
      }

      # 2. Linux-only configuration
      (lib.optionalAttrs (!isDarwin) {
        i18n.defaultLocale = "en_US.UTF-8";
      })
    ]
  );
}

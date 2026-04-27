{
  config,
  lib,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.core.system.localeChicago;
in
{
  options.myFeatures.core.system.localeChicago.enable =
    lib.mkEnableOption "Missouri Locale & Timezone Settings";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. Cross-platform settings
      {
        time.timeZone = "America/Chicago";
      }

      # 2. Linux-only settings (Shielded from macOS)
      (lib.optionalAttrs (!isDarwin) {
        i18n.defaultLocale = "en_US.UTF-8";
        console.keyMap = "us";
        services.xserver.xkb.layout = "us";
      })
    ]
  );
}

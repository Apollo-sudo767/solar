{ config, lib, ... }:

let
  cfg = config.myFeatures.core.localeChicago;
in
{
  options.myFeatures.core.localeChicago.enable = lib.mkEnableOption "Missouri Locale & Timezone Settings";

  config = lib.mkIf cfg.enable {
    time.timeZone = "America/Chicago";
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";
    services.xserver.xkb.layout = "us";
  };
}

{ config, lib, ... }: # <-- ADDED pkgs.stdenv.isDarwin

let
  cfg = config.myFeatures.core.localeChicago;
in
{
  options.myFeatures.core.localeChicago.enable = lib.mkEnableOption "Missouri Locale & Timezone Settings";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # 1. Cross-platform settings
    {
      time.timeZone = "America/Chicago";
    }

    # 2. Linux-only settings (Shielded from macOS)
    {
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "us";
      services.xserver.xkb.layout = "us";
    }
  ]);
}

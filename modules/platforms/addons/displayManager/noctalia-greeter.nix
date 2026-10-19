{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  config = lib.mkIf (cfg.manager == "noctalia-greeter") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.displayManager.noctalia-greeter = {
          enable = true;
          settings = {
            cursor.size = 24;
            keyboard.layout = "us";
            appearance.wallpaper.path =
              if (config.stylix.enable or false) && (config.stylix.image or null) != null then
                "${config.stylix.image}"
              else
                "${../../../../assets/wallpapers/space.png}";
            output.name = "DP-2";
          };
          cursorTheme = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
          };
        };
      })
    ]
  );
}

{
  config,
  lib,
  pkgs,
  inputs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.stylix;
in
{
  imports = [
    (
      if isDarwin then
        inputs.stylix-unstable.darwinModules.stylix
      else
        inputs.stylix-unstable.nixosModules.stylix
    )
  ];

  options.myFeatures.platforms.addons.stylix = {
    enable = lib.mkEnableOption "Universal Stylix Styling";

    scheme = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.str lib.types.path); # Allow both types
      default = null;
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        stylix = {
          enable = true;

          image =
            if (cfg.wallpaper != null) then
              cfg.wallpaper
            else
              pkgs.nixos-icons + "/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";

          # FIX: Removed quotes and ${} to pass the path literal directly
          base16Scheme =
            if (cfg.scheme != null) then cfg.scheme else pkgs.base16-schemes + "/share/themes/nord.yaml";

          polarity = "dark";

          targets = {
          }
          // lib.optionalAttrs (!isDarwin) {
            limine.enable = false;
            plymouth = {
              enable = true;
              logoAnimated = true;
              logo = pkgs.nixos-icons + "/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";
            };
          };
        };
      }

      (lib.optionalAttrs (!isDarwin) {
        qt = {
          enable = true;
          platformTheme = lib.mkForce "kde";
          style = lib.mkForce "kvantum";
        };

        stylix.targets.qt = {
          enable = true;
          platform = lib.mkForce "qtct";
        };
      })
    ]
  );
}

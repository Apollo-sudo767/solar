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
  cfg = config.myFeatures.systems.stylix or { enable = false; };
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

  options.myFeatures.systems.stylix = {
    enable = lib.mkEnableOption "Universal Stylix Styling";
    scheme = lib.mkOption { type = lib.types.path; };
    wallpaper = lib.mkOption { type = lib.types.path; };
  };

  config = lib.mkIf (cfg.enable or false) (
    lib.mkMerge [
      {
        stylix = {
          enable = true;
          image = cfg.wallpaper;
          base16Scheme = cfg.scheme;
          polarity = "dark";

          targets = {
          }
          // lib.optionalAttrs (!isDarwin) {
            # Only these targets crash the Mac
            plymouth.enable = true;
            gnome.enable = true;
            qt.enable = true;
          };
        };
      }
      (lib.optionalAttrs (!isDarwin) {
        qt = {
          enable = true;
          platformTheme = lib.mkForce "qt5ct";
          style = lib.mkForce "kvantum";
        };
      })
    ]
  );
}

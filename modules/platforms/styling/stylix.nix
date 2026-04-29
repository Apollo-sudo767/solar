{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal,
  ...
}:

let
  inherit isDarwin isTotal;
  cfg = config.myFeatures.platforms.styling.stylix;
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

  options.myFeatures.platforms.styling.stylix = {
    enable = lib.mkEnableOption "Stylix Framework";
    scheme = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      description = "Path to the base16 scheme file.";
    };
    wallpaper = lib.mkOption {
      type = lib.types.path;
      description = "Path to the wallpaper image.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Universal Stylix (Base Theme & Common Targets)
      {
        stylix = {
          enable = true;
          image = cfg.wallpaper;
          base16Scheme = cfg.scheme;
        }
        // lib.optionalAttrs (!isDarwin) {
          cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
            size = 24;
          };
        }
        // {
          fonts = {
            monospace = {
              package = pkgs.nerd-fonts.jetbrains-mono;
              name = "JetBrainsMono Nerd Font Mono";
            };
            sansSerif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans";
            };
          };
        };
      }

      # Target Handling
      (lib.mkIf (!isDarwin) {
        stylix.targets = {
          gnome.enable = config.myFeatures.platforms.desktops.gnome.enable or false;
          qt.enable = config.myFeatures.platforms.desktops.kde.enable or false;
          plymouth.enable = config.boot.boot.nix or false;
        };
      })
    ]
  );
}

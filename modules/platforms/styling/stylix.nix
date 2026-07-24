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
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.attrs);
      default = null;
      description = "Path to the base16 scheme file or an attribute set. If null, Stylix generates colors from the wallpaper.";
    };
    wallpaper = lib.mkOption {
      type = lib.types.path;
      description = "Path to the wallpaper image.";
    };
  };

  config = lib.mkMerge [
    # Ensure Stylix Home Manager module is always available if home-manager is used
    # We only import it manually if Stylix is NOT enabled, because Stylix's NixOS/Darwin
    # module will automatically import it if it IS enabled.
    {
      home-manager.sharedModules = [
        (lib.mkIf cfg.enable {
          stylix.targets = {
            helix.enable = config.myFeatures.programs.terminal.helix.enable or false;
            ghostty.enable = config.myFeatures.programs.terminal.ghostty.enable or false;
            noctalia-shell.enable = config.myFeatures.platforms.addons.noctalia-shell.enable or false;
          };
        })
      ]
      ++ lib.optional (!config.stylix.enable) inputs.stylix-unstable.homeModules.stylix;
    }

    # Universal Stylix (Base Theme & Common Targets)
    (lib.mkIf cfg.enable {
      stylix = {
        enable = true;
        image = cfg.wallpaper;
        polarity = "dark";
        opacity.terminal = 0.85;
      }
      // lib.optionalAttrs (cfg.scheme != null) {
        base16Scheme = cfg.scheme;
      }
      // lib.optionalAttrs (!isDarwin) {
        targets.qt.enable = !(config.myFeatures.platforms.desktops.kde.enable or false);
        targets.qt.platform = lib.mkDefault "qtct";

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
    })

    # Target Handling
    (
      if isDarwin then
        { }
      else
        lib.mkIf cfg.enable {
          stylix.targets = {
            gnome.enable = config.myFeatures.platforms.desktops.gnome.enable or false;
            plymouth.enable = config.myFeatures.core.boot.boot.enable or false;
            spicetify.enable = config.myFeatures.programs.utilities.spicetify.enable or false;
            kmscon.enable = false;
            limine.enable = false;
          };
        }
    )
  ];
}

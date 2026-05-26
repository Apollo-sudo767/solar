{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  ...
}:
let
  cfg = config.myFeatures.platforms.desktops.paneru;
in
{
  imports = [
    # Use the darwinModule instead of the homeModule
    inputs.paneru.darwinModules.paneru
  ];

  options.myFeatures = {
    platforms.desktops.paneru = {
      enable = lib.mkEnableOption "Paneru scrollable tiling window manager for macOS";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    # This now uses the nix-darwin service provided by the flake
    services.paneru = {
      enable = true;
      package = inputs.paneru.packages.${pkgs.stdenv.system}.default;

      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          horizontal_mouse_warp = true;
          # Adding the preset widths from the docs for a better experience
          preset_column_widths = [
            0.25
            0.33
            0.5
            0.66
            0.75
          ];
        };

        bindings = {
          window_focus_west = "cmd - h";
          window_focus_east = "cmd - l";
          window_resize = "alt - r";
          window_center = "alt - c";
          quit = "ctrl + alt - q";
        };

        # Note: nix-darwin doesn't have a direct 'source' option in the service
        # like the HM one might, but you can keep your assets mapped here:
        # (This assumes you manage your home directory separately)
      };
    };

    # System-level requirement for Paneru to work correctly
    system.defaults.dock.mru-spaces = false;
    system.defaults.spaces.spans-displays = false; # Required for "Separate Spaces"
  };
}

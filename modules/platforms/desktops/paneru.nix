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
  cfg = config.myFeatures.platforms.desktops.paneru;
in
{
  imports = [
    inputs.paneru.darwinModules.paneru
  ];

  options.myFeatures.platforms.desktops.paneru = {
    enable = lib.mkEnableOption "Paneru scrollable tiling window manager for macOS";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    services.paneru = {
      enable = true;
      package = inputs.paneru.packages.${pkgs.stdenv.system}.default;

      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          # Fixed: Changed from 'true' to '1' to satisfy the i16 requirement
          horizontal_mouse_warp = 1;
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
      };
    };

    system.defaults.dock.mru-spaces = false;
    system.defaults.spaces.spans-displays = false;
  };
}

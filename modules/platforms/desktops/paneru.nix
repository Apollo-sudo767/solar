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
  # Solar-Safe reference: Fallback to a string if userHost isn't yet merged
  username = if (builtins.hasAttr "userHost" config) then config.userHost else null;
in
{
  options.myFeatures = {
    platforms = {
      desktops = {
        paneru = {
          enable = lib.mkEnableOption "Paneru scrollable tiling window manager for macOS";
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin && username != null) {
    # solar-autoscanner: Connects Paneru to the Solar Home Manager bridge
    home-manager.users.${username} = {
      imports = [ inputs.paneru.homeModules.paneru ];

      config = {
        services.paneru = {
          enable = true;
          # Resolves the 'system' rename warning from your logs
          package = inputs.paneru.packages.${pkgs.system}.default;

          settings = {
            options = {
              focus_follows_mouse = true;
              mouse_follows_focus = true;
              horizontal_mouse_warp = true;
            };

            bindings = {
              window_focus_west = "cmd - h";
              window_focus_east = "cmd - l";
              window_resize = "alt - r";
              window_center = "alt - c";
              quit = "ctrl + alt - q";
            };

            # Dynamically resolve home directory for the Solar asset library
            source = [
              {
                path = "${
                  config.home-manager.users.${username}.home.homeDirectory
                }/.config/nix-config/assets/wallpapers";
                recursive = true;
              }
            ];
          };
        };
      };
    };
  };
}

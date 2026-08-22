{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      prefer-no-csd = { };

      layout = {
        default-column-width = lib.mkDefault { proportion = 0.5; };
        preset-column-widths._children = lib.mkDefault [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        background-color = lib.mkDefault "transparent";
        gaps = lib.mkDefault 0;
        focus-ring.off = lib.mkDefault { };
        border = lib.mkDefault {
          width = 2;
          active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
          inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
        };
      };

      _children = [
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "noctalia-bar-default";
              };
            }
            {
              background-effect = {
                blur = true;
                xray = true;
              };
            }
          ];
        }
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "^wallpaper$";
              };
            }
            { place-within-backdrop = true; }
          ];
        }
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "^noctalia-wallpaper$";
              };
            }
            { place-within-backdrop = true; }
          ];
        }
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "^noctalia-overview$";
              };
            }
            { place-within-backdrop = true; }
          ];
        }
        {
          window-rule._children = [
            { focus-ring.off = { }; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "firefox";
              };
            }
            { border.off = { }; }
            { focus-ring.off = { }; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "com.mitchellh.ghostty";
              };
            }
            {
              background-effect = {
                blur = true;
                xray = true;
              };
            }
            { draw-border-with-background = false; }
            { border.off = { }; }
            {
              focus-ring = {
                width = 2;
                active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
                inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
              };
            }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "^steam_app_";
              };
            }
            {
              match._props = {
                app-id = "^gamescope$";
              };
            }
            { open-fullscreen = true; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "^steam$";
                title = "^notificationtoasts_[0-9]+_desktop$";
              };
            }
            {
              default-floating-position._props = {
                x = 16;
                y = 16;
                relative-to = "bottom-right";
              };
            }
            { open-floating = true; }
            { open-focused = false; }
          ];
        }
      ];
    };
  };
}

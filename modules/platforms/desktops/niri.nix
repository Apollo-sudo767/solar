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
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  options.myFeatures.platforms.desktops.niri = {
    enable = lib.mkEnableOption "Niri Window Manager";
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Niri settings";
    };
    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra Niri configuration in KDL format";
    };
  };

  # Shield everything
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        programs.niri.enable = true;
        nix.settings = {
          substituters = [ "https://niri.cachix.org" ];
          trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
        };

        myFeatures.platforms.desktops.niri.settings = {
          spawn-at-startup = [
            {
              command = [
                "sh"
                "-c"
                "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start graphical-session.target"
              ];
            }
          ]
          ++ (lib.optionals config.myFeatures.platforms.addons.noctalia-shell.enable [
            { command = [ "noctalia-shell" ]; }
          ])
          ++ (lib.optionals config.myFeatures.platforms.addons.noctalia-v5.enable [
            { command = [ "noctalia" ]; }
          ]);
        };

        environment.systemPackages =
          with pkgs;
          [
            xwayland-satellite
            networkmanagerapplet
            thunar
            awww
            brightnessctl
          ]
          ++
            lib.optionals
              (
                !config.myFeatures.platforms.addons.noctalia-shell.enable
                && !config.myFeatures.platforms.addons.noctalia-v5.enable
              )
              [
                fuzzel
                mako
                swaynotificationcenter
                swaybg
                swayidle
                swaylock
              ];

        home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          imports = [ inputs.niri.homeModules.niri ];
          programs.niri.settings = cfg.settings;
        });
      })
    ]
  );
}

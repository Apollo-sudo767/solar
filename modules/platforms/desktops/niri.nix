{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  imports = [ inputs.niri.nixosModules.niri ];

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
    modKey = lib.mkOption {
      type = lib.types.enum [
        "super"
        "left-alt"
      ];
      default = "left-alt";
      description = "Modifier key for Niri bindings";
    };
  };

  # Shield everything
  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
      # package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
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
      let
        niri-lock = pkgs.writeShellScriptBin "niri-lock" ''
          if ${pkgs.procps}/bin/pgrep -x "noctalia" >/dev/null 2>&1 && ${pkgs.which}/bin/which noctalia >/dev/null 2>&1; then
            noctalia msg session lock && exit 0
          fi

          if ${pkgs.procps}/bin/pgrep -x "noctalia-shell" >/dev/null 2>&1 && ${pkgs.which}/bin/which noctalia-shell >/dev/null 2>&1; then
            noctalia-shell ipc call lockScreen lock && exit 0
          fi

          if ${pkgs.which}/bin/which swaylock >/dev/null 2>&1; then
            exec swaylock
          elif ${pkgs.which}/bin/which hyprlock >/dev/null 2>&1; then
            exec hyprlock
          elif ${pkgs.which}/bin/which gtklock >/dev/null 2>&1; then
            exec gtklock
          elif ${pkgs.which}/bin/which waylock >/dev/null 2>&1; then
            exec waylock
          else
            exec loginctl lock-session
          fi
        '';
        lock-screen = pkgs.writeShellScriptBin "lock-screen" ''
          exec niri-lock "$@"
        '';
      in
      with pkgs;
      [
        niri-lock
        lock-screen
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
      programs.niri = {
        inherit (cfg) settings;
        config = lib.mkIf (cfg.extraConfig != [ ]) (lib.concatStringsSep "\n" cfg.extraConfig);
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/niri"
              ".cache/mesa_shader_cache"
              ".config/dconf"
            ];
          });
        };
  };
}

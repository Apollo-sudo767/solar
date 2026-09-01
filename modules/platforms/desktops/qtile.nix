{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.qtile;
in
{
  options.myFeatures.platforms.desktops.qtile = {
    enable = lib.mkEnableOption "Qtile (Python-based Dynamic Tiling Window Manager)";

    backend = lib.mkOption {
      type = lib.types.enum [
        "wayland"
        "x11"
      ];
      default = "wayland";
      description = "Display backend for Qtile (wayland or x11)";
    };

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra Python code appended to config.py";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.windowManager.qtile = {
      enable = true;
      inherit (cfg) backend;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      libnotify
      brightnessctl
      fuzzel
      grim
      slurp
    ];

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xdg.configFile."qtile/config.py".text = ''
        from libqtile import bar, layout, widget, hook
        from libqtile.config import Click, Drag, Group, Key, Match, Screen
        from libqtile.lazy import lazy

        mod = "mod4"
        terminal = "ghostty"

        keys = [
            Key([mod], "h", lazy.layout.left()),
            Key([mod], "l", lazy.layout.right()),
            Key([mod], "j", lazy.layout.down()),
            Key([mod], "k", lazy.layout.up()),
            Key([mod], "q", lazy.spawn(terminal)),
            Key([mod, "shift"], "q", lazy.spawn("firefox")),
            Key([mod], "space", lazy.spawn("fuzzel")),
            Key([mod], "d", lazy.spawn("fuzzel")),
            Key([mod], "c", lazy.window.kill()),
            Key([mod, "shift"], "r", lazy.reload_config()),
            Key([mod, "shift"], "e", lazy.shutdown()),
            Key([mod], "f", lazy.window.toggle_fullscreen()),
            Key([mod], "v", lazy.window.toggle_floating()),
        ]

        groups = [Group(i) for i in "123456789"]

        for i in groups:
            keys.extend([
                Key([mod], i.name, lazy.group[i.name].toscreen()),
                Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True)),
            ])

        layouts = [
            layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=2, margin=4),
            layout.Max(),
        ]

        widget_defaults = dict(
            font="sans",
            fontsize=12,
            padding=3,
        )

        screens = [
            Screen(
                bottom=bar.Bar(
                    [
                        widget.GroupBox(),
                        widget.Prompt(),
                        widget.WindowName(),
                        widget.Systray(),
                        widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
                        widget.QuickExit(),
                    ],
                    24,
                ),
            ),
        ]

        ${lib.concatStringsSep "\n" cfg.extraConfig}
      '';
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/qtile"
            ];
          });
        };
  };
}

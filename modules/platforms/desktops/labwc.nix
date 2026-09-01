{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.labwc;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable or false;
in
{
  options.myFeatures.platforms.desktops.labwc = {
    enable = lib.mkEnableOption "Labwc (Openbox-inspired Stacking Wayland Compositor)";

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra XML configuration lines for labwc rc.xml";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.labwc.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      libnotify
      brightnessctl
      fuzzel
      waybar
      swaybg
      swayidle
      swaylock
      grim
      slurp
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      config.labwc.default = [
        "wlr"
        "gtk"
      ];
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xdg.configFile."labwc/rc.xml".text = ''
        <?xml version="1.0"?>
        <labwc_config>
          <theme>
            <name>Adwaita</name>
            <cornerRadius>8</cornerRadius>
          </theme>
          <keyboard>
            <default />
            <keybind key="W-q"><action name="Execute" command="ghostty" /></keybind>
            <keybind key="W-S-q"><action name="Execute" command="firefox" /></keybind>
            <keybind key="W-space"><action name="Execute" command="fuzzel" /></keybind>
            <keybind key="W-d"><action name="Execute" command="fuzzel" /></keybind>
            <keybind key="W-c"><action name="Close" /></keybind>
            <keybind key="W-f"><action name="ToggleFullscreen" /></keybind>
            <keybind key="W-S-e"><action name="Exit" /></keybind>
            <keybind key="A-Tab"><action name="NextWindow" /></keybind>
            <keybind key="A-S-Tab"><action name="PreviousWindow" /></keybind>
          </keyboard>
          <mouse>
            <default />
          </mouse>
          ${lib.concatStringsSep "\n" cfg.extraConfig}
        </labwc_config>
      '';

      xdg.configFile."labwc/autostart".text = ''
        waybar &
      '';
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/labwc"
            ];
          });
        };
  };
}

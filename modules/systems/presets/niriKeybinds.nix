{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.presets.niriKeybinds;
in
{
  options.myFeatures.systems.presets.niriKeybinds.enable = lib.mkEnableOption "Apollo's Niri Keybinds";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.mapAttrs (name: _: {
      programs.niri.settings.binds = with config.lib.niri.actions; {
        # Ported from your request:
        "Mod+Q".action = spawn "ghostty";
        "Mod+Shift+Q".action = spawn "zen";
        "Mod+D".action = spawn "fuzzel";
        "Mod+C".action = close-window;
        "Print".action = screenshot;

        # Standard Nav (Phanes Parity)
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Up".action = focus-window-up;
        "Mod+Down".action = focus-window-down;

        "XF86AudioRaiseVolume".action = spawn "pamixer" "-i" "5";
        "XF86AudioLowerVolume".action = spawn "pamixer" "-d" "5";
        "XF86AudioMute".action = spawn "pamixer" "-t";
      };
    }) config.myFeatures.users;
  };
}

{ config, lib, pkgs, isStable, ... }: # Added isStable

let
  cfg = config.myFeatures.systems.presets.niriKeybinds;
  # Set version based on the host's stability toggle
  dynamicVersion = if isStable then "25.11" else "26.05";
in
{
  options.myFeatures.systems.presets.niriKeybinds.enable = lib.mkEnableOption "Apollo's Niri Keybinds";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.mapAttrs (name: _: {
      # This satisfies the error you were seeing
      home.stateVersion = dynamicVersion;

      programs.niri.settings.binds = with config.lib.niri.actions; {
        "Mod+Q".action = spawn "ghostty";
        "Mod+Shift+Q".action = spawn "zen";
        "Mod+D".action = spawn "fuzzel";
        "Mod+C".action = close-window;
        "Print".action = screenshot;

        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Up".action = focus-window-up;
        "Mod+Down".action = focus-window-down;

        "XF86AudioRaiseVolume".action = spawn "pamixer" "-i" "5";
        "XF86AudioLowerVolume".action = spawn "pamixer" "-d" "5";
        "XF86AudioMute".action = spawn "pamixer" "-t";
      };
    }) (lib.genAttrs config.myFeatures.core.users.usernames (name: { inherit name; }));
  };
}

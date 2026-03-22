{ config, lib, pkgs, isStable, inputs, ... }:

let
  cfg = config.myFeatures.systems.presets.niriKeybinds;
  # Use the host's stability toggle to determine the stateVersion
  dynamicVersion = if isStable then "25.11" else "26.05";
in
{
  options.myFeatures.systems.presets.niriKeybinds.enable = lib.mkEnableOption "Apollo's Niri Keybinds";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: { config, ... }: {
      
      # FIX: This file now "owns" the Niri module handshake
      imports = [ inputs.niri.homeModules.niri ];

      home.stateVersion = dynamicVersion;

      programs.niri = {
        enable = true; # Ensures the niri binary and service are managed
        
        settings.binds = let
          actions = config.lib.niri.actions;
        in {
          # Standard App Launches
          "Mod+Q".action = actions.spawn "ghostty";
          "Mod+Shift+Q".action = actions.spawn "zen";
          "Mod+D".action = actions.spawn "fuzzel";
          "Mod+C".action = actions.close-window;

          # Built-in Niri Screenshot (Raw Attribute Method)
          "Print".action.screenshot = { };
          "Ctrl+Print".action.screenshot-screen = { };
          "Alt+Print".action.screenshot-window = { };

          # Navigation
          "Mod+Left".action = actions.focus-column-left;
          "Mod+Right".action = actions.focus-column-right;
          "Mod+Up".action = actions.focus-window-up;
          "Mod+Down".action = actions.focus-window-down;

          # Media Keys
          "XF86AudioRaiseVolume".action = actions.spawn [ "pamixer" "-i" "5" ];
          "XF86AudioLowerVolume".action = actions.spawn [ "pamixer" "-d" "5" ];
          "XF86AudioMute".action = actions.spawn [ "pamixer" "-t" ];
        };
      };
    });
  };
}

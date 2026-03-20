{ pkgs, ... }: {
  flake.nixosModules.myFeatures.xdgPortals = { ... }: {
    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
          xdg-desktop-portal-kde   # Added for Plasma 6
          xdg-desktop-portal-wlr   # Keep for wlroots-based TWMs
        ];
        
        # This tells each environment which portal to prioritize
        config = {
          common.default = [ "gtk" ];
          niri.default = [ "gnome" "gtk" ];
          hyprland.default = [ "hyprland" "gtk" ];
          plasma.default = [ "kde" "gtk" ];
          gnome.default = [ "gnome" "gtk" ];
        };
      };
    };
  };
}

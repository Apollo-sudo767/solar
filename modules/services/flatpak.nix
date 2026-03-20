{ ... }: {
  flake.nixosModules.myFeatures.flatpak = { ... }: {
    services.flatpak.enable = true;
    # Ensures XDG portals work for file picking/screensharing
    xdg.portal.enable = true; 
  };
}

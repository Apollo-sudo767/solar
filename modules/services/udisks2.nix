{ ... }: {
  flake.nixosModules.myFeatures.udisks2 = { ... }: {
    services.udisks2.enable = true;
    services.dbus.enable = true;
    
    # Optional: GVFS is often needed alongside udisks2 for 
    # file managers (like Thunar/Nautilus) to show "Trash" and "Network"
    services.gvfs.enable = true;
  };
}

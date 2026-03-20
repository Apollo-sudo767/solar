{ config, pkgs, ... }:

{
  # ... networking and other standard NixOS boilerplate

  myFeatures = {
    # CORE FEATURES (The Must-Haves)
    core = {
      nix-settings.enable = true;
      cli.enable = true;
      boot.enable = true;
      security.enable = true;
      users.enable = true;
    };

    # SYSTEMS (The Environment)
    systems = {
      audio.enable = true;
      xdgPortals.enable = true;
      styling.enable = true;
      
      # SELECT YOUR LOGIN MANAGER HERE:
      # Options: "tuigreet", "gdm", "sddm", or "none"
      displayManager.manager = "tuigreet"; 
    };

    # HARDWARE (The Drivers)
    hardware = {
      graphics.enable = true;
      nvidia.enable = true; # Enabled for your 4070 Ti
    };

    # PROGRAMS & SERVICES
    programs.flatpak.enable = true;
    services.udisks2.enable = true;
  };
}

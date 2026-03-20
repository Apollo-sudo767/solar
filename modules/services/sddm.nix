{ pkgs, ... }: {
  flake.nixosModules.myFeatures.plasma = { ... }: {
    # Enable the X11 windowing system (needed as a base for Plasma)
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment
    services.desktopManager.plasma6.enable = true;

    # Configure the Display Manager to recognize Plasma
    services.displayManager = {
      sddm.enable = true; # SDDM is the standard for KDE
      # If you prefer GDM, you can keep your gdm.nix feature enabled instead
      defaultSession = "plasma";
    };

    # Essential KDE Utilities (The "Launcher" and more)
    environment.systemPackages = with pkgs; [
      kdePackages.krunner      # The actual "Plasma Launcher" (Alt+Space)
      kdePackages.plasma-nm    # Network Manager applet
      kdePackages.spectacle    # Screenshot tool
      kdePackages.dolphin      # File manager
    ];
  };
}

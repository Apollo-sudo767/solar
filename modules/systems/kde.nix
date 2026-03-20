{ pkgs, ... }: {
  flake.nixosModules.myFeatures.plasma = { ... }: {
    # Enable the X11 windowing system (base for Plasma)
    services.xserver.enable = true;

    # Enable the KDE Plasma 6 Desktop Environment
    services.desktopManager.plasma6.enable = true;

    # Essential KDE Utilities & Applets
    environment.systemPackages = with pkgs; [
      kdePackages.krunner       # The "Alt+Space" Launcher
      kdePackages.plasma-nm     # Network Manager applet
      kdePackages.plasma-pa     # PulseAudio/Pipewire volume control
      kdePackages.dolphin       # File Manager
      kdePackages.spectacle     # Screenshot tool
      kdePackages.ark           # Archive manager
    ];

    # Ensure Plasma uses the correct portal
    xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}

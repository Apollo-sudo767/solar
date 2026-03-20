{ pkgs, ... }: {
  flake.nixosModules.myFeatures.gnome = { ... }: {
    services.xserver.desktopManager.gnome.enable = true;

    # Exclude some GNOME bloat if you want to keep your Gruvbox feel
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany # GNOME Web
    ];
  };
}

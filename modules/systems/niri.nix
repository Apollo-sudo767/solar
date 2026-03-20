{ pkgs, ... }: {
  flake.nixosModules.myFeatures.niri = { ... }: {
    programs.niri.enable = true;
    
    environment.systemPackages = with pkgs; [
      fuzzel
      xwayland-satellite
      mako
      swaybg
      hypridle
      swaylock
    ];
  };
}

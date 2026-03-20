{ pkgs, ... }: {
  flake.nixosModules.myFeatures.gdm = { ... }: {
    services.displayManager = {
      gdm.enable = true;
      sessionPackages = [ pkgs.niri ];
    };
  };
}

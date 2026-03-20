{ ... }: {
  flake.nixosModules.myFeatures.wifi = { ... }: {
    networking.networkmanager.enable = true;
  };
}

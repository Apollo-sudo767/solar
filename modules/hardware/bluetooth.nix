{ ... }: {
  flake.nixosModules.myFeatures.bluetooth = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
    environment.systemPackages = [ pkgs.bluez ];
  };
}

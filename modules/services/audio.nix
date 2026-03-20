{ ... }: {
  flake.nixosModules.myFeatures.audio = { ... }: {
    security.rtkit.enable = true; # Recommended for Pipewire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}

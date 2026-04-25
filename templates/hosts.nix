{
  # Peak-able metadata for flake.nix
  meta = {
    system = "x86_64-linux"; # or "aarch64-darwin"
    stable = false;
  };

  module =
    { lib, ... }:
    {
      imports = [ ./hardware-configuration.nix ];

      # OS-Aware State Version
      system.stateVersion = if lib.hasInfix "darwin" builtins.currentSystem then 5 else "26.05";

      myFeatures = {
        # Use Composed Templates here
        workstation.enable = true;
        server.minecraft.enable = true;
      };
    };
}

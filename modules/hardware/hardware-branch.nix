{ lib, config, ... }:

{
  # We leave options empty here to avoid the "already declared" error.
  options.myFeatures.hardware = {};

  config = {
    # This logic just ensures that if ANY GPU is enabled, the 
    # base graphics.nix module is also triggered.
    myFeatures.hardware.graphics.enable = lib.mkIf (
      config.myFeatures.hardware.amd.gpu || 
      config.myFeatures.hardware.nvidia.enable || 
      config.myFeatures.hardware.intel.enable
    ) true;
  };
}

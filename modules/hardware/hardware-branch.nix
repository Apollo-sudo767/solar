{ lib, config, isDarwin, ... }: # Added isDarwin [cite: 12]

{
  options.myFeatures.hardware = {};

  # Wrap configuration in optionalAttrs to prevent reading 
  # hardware attributes on macOS [cite: 13]
  config = lib.optionalAttrs (!isDarwin) {
    myFeatures.hardware.graphics.enable = lib.mkIf (
      config.myFeatures.hardware.amd.gpu || 
      config.myFeatures.hardware.nvidia.enable || 
      config.myFeatures.hardware.intel.enable
    ) true;
  };
}

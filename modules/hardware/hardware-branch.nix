{
  lib,
  config,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

{
  options.myFeatures.hardware = { };

  # Completely erase the graphics binding logic on macOS
  config = lib.optionalAttrs (!isDarwin) {
    myFeatures.hardware.graphics.enable = lib.mkIf (
      config.myFeatures.hardware.amd.gpu
      || config.myFeatures.hardware.nvidia.enable
      || config.myFeatures.hardware.intel.enable
    ) true;
  };
}

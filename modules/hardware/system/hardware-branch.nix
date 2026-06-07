{
  lib,
  config,
  isDarwin,
  isTotal,
  ...
}:

{
  options.myFeatures.hardware.system.hardware-branch = { };

  # Completely erase the graphics binding logic on macOS
  config = lib.optionalAttrs (!isDarwin) {
    myFeatures.hardware.system.graphics.enable = lib.mkIf (
      config.myFeatures.hardware.cpu-gpu.amd.gpu
      || config.myFeatures.hardware.cpu-gpu.nvidia.enable
      || config.myFeatures.hardware.cpu-gpu.intel.enable
    ) true;
  };
}

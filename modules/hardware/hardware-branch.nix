{
  lib,
  config,
  pkgs,
  isTotal,
  ...
}:

{
  options.myFeatures.hardware = { };

  # Safely bind the graphics logic to Linux only
  config = lib.mkIf pkgs.stdenv.isLinux {
    myFeatures.hardware.graphics.enable = lib.mkIf (
      config.myFeatures.hardware.amd.gpu
      || config.myFeatures.hardware.nvidia.enable
      || config.myFeatures.hardware.intel.enable
    ) true;
  };
}

{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.virtualization;
in
{
  options.myFeatures.suites.virtualization = {
    enable = lib.mkEnableOption "Virtualization & Containers Suite (Podman, Docker, QEMU/KVM, Virt-Manager)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core.system.virtualization.enable = lib.mkDefault true;
  };
}

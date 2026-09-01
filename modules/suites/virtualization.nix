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

    docker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Docker container engine.";
      };
    };

    libvirt = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Libvirt/QEMU hypervisor subsystem.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core.system.virtualization = {
      enable = lib.mkDefault true;
      docker = lib.mkIf cfg.docker.enable (lib.mkDefault true);
      libvirt = lib.mkIf cfg.libvirt.enable (lib.mkDefault true);
    };
  };
}

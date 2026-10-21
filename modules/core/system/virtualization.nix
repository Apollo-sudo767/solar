# modules/core/system/virtualization.nix
# ============================================================================
# Container & Virtual Machine Virtualization (Docker & Libvirt/KVM)
# ============================================================================
# Configures Docker and/or Libvirt (QEMU/KVM), automatically grants group
# permissions (`docker`, `libvirtd`) to all declared users, and persists
# container/VM storage under `/persist` when ephemeral root is enabled.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.core.system.virtualization;
in
{
  options.myFeatures.core.system.virtualization = {
    enable = lib.mkEnableOption "Virtualization Suite";
    docker = lib.mkEnableOption "Docker Engine";
    libvirt = lib.mkEnableOption "Libvirt/Virt-Manager";
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      docker.enable = cfg.docker;
      libvirtd.enable = cfg.libvirt;
    };

    # Grant declared system users access to the Docker socket and/or Libvirt daemon
    users.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      extraGroups = (lib.optional cfg.docker "docker") ++ (lib.optional cfg.libvirt "libvirtd");
    });

    # Persist Docker images/volumes and Libvirt VM disks across reboots
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          directories =
            (lib.optional cfg.docker "/var/lib/docker") ++ (lib.optional cfg.libvirt "/var/lib/libvirt");
        };
  };
}

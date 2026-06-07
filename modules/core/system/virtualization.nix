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

    # Automatically add users to the correct groups
    users.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      extraGroups = (lib.optional cfg.docker "docker") ++ (lib.optional cfg.libvirt "libvirtd");
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          directories =
            (lib.optional cfg.docker "/var/lib/docker") ++ (lib.optional cfg.libvirt "/var/lib/libvirt");
        };
  };
}

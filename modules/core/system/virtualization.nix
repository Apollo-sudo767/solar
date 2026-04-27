{
  config,
  lib,
  pkgs,
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
    users.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      extraGroups = (lib.optional cfg.docker "docker") ++ (lib.optional cfg.libvirt "libvirtd");
    });
  };
}

{ config, lib, pkgs, isDarwin, ... }:

let
  cfg = config.myFeatures.core.virtualization;
in
{
  options.myFeatures.core.virtualization = {
    enable = lib.mkEnableOption "Virtualization Suite";
    docker = lib.mkEnableOption "Docker Engine";
    libvirt = lib.mkEnableOption "Libvirt/Virt-Manager";
  };

  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    virtualisation = {
      docker.enable = cfg.docker;
      libvirtd.enable = cfg.libvirt;
    };

    # Automatically add users to the correct groups
    users.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      extraGroups = 
        (lib.optional cfg.docker "docker") ++ 
        (lib.optional cfg.libvirt "libvirtd");
    });
  });
}

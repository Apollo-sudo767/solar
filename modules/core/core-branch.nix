{
  lib,
  config,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core;
in
{
  options.myFeatures.core = {
    enable = lib.mkEnableOption "Core System Foundation";
    usePersistence = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Switch from standard users to persistent SOPS-backed users.";
    };
    virtualization = {
      docker = lib.mkEnableOption "Docker Engine";
      libvirt = lib.mkEnableOption "Virt-Manager/VMs";
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core = {
      # Only default the Linux-specific features to true on Linux
      boot.enable = lib.mkIf pkgs.stdenv.isLinux (lib.mkDefault true);
      nix-settings.enable = lib.mkDefault true;
      fonts.enable = lib.mkDefault true;
      localeChicago.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
      users.enable = lib.mkDefault true;

      virtualization = {
        docker = lib.mkIf (cfg.virtualization.docker && pkgs.stdenv.isLinux) (lib.mkDefault true);
        libvirt = lib.mkIf (cfg.virtualization.libvirt && pkgs.stdenv.isLinux) (lib.mkDefault true);
      };
    };
  };
}

{
  lib,
  config,
  pkgs,
  isTotal,
  isDarwin,
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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Universal Core Features (Loaded on both Mac and Linux)
      {
        myFeatures.core = {
          nix-settings.enable = lib.mkDefault true;
          fonts.enable = lib.mkDefault true;
          localeChicago.enable = lib.mkDefault true;
          ssh.enable = lib.mkDefault true;
          users.enable = lib.mkDefault true;
        };
      }

      # Linux-Only Core Features (Completely erased from macOS view)
      (lib.optionalAttrs (!isDarwin) {
        myFeatures.core.boot.enable = lib.mkDefault true;
        myFeatures.core.virtualization.docker = lib.mkIf cfg.virtualization.docker (lib.mkDefault true);
        myFeatures.core.virtualization.libvirt = lib.mkIf cfg.virtualization.libvirt (lib.mkDefault true);
      })
    ]
  );
}

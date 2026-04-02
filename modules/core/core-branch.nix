{ lib, config, ... }:

let
  cfg = config.myFeatures.core;
in
{
  options.myFeatures.core = {
    enable = lib.mkEnableOption "Core System Foundation";
    
    # New toggle for persistence mode
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
      boot.enable = lib.mkDefault true;
      nix-settings.enable = lib.mkDefault true;
      fonts.enable = lib.mkDefault true;
      localeChicago.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;

      # Logic to choose between the two modules
      users.enable = lib.mkIf (!cfg.usePersistence) (lib.mkDefault true);
      persistentUsers.enable = lib.mkIf (cfg.usePersistence) (lib.mkDefault true);
    };
  };
}

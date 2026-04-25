{ lib, config, isDarwin, ... }: # Added isDarwin [cite: 88]

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

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      myFeatures.core = {
        # Shield Linux-only core defaults [cite: 94]
        boot.enable = lib.mkIf (!isDarwin) (lib.mkDefault true);
        nix-settings.enable = lib.mkDefault true;
        fonts.enable = lib.mkDefault true;
        localeChicago.enable = lib.mkDefault true;
        ssh.enable = lib.mkDefault true;
        users.enable = lib.mkDefault true; 
        
        virtualization = {
          # Added !isDarwin check to prevent crashes on Mac [cite: 94]
          docker = lib.mkIf (cfg.virtualization.docker && !isDarwin) (lib.mkDefault true);
          libvirt = lib.mkIf (cfg.virtualization.libvirt && !isDarwin) (lib.mkDefault true);
        };
      };
    }
  ]);
}

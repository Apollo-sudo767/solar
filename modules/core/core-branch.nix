{ lib, config, ... }:

let
  cfg = config.myFeatures.core;
in
{
  options.myFeatures.core = {
    enable = lib.mkEnableOption "Core System Foundation";
    virtualization = {
      docker = lib.mkEnableOption "Docker Engine";
      libvirt = lib.mkEnableOption "Virt-Manager/VMs";
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.core = {
      boot.enable = lib.mkDefault true;
      nix-settings.enable = lib.mkDefault true;
      users.enable = lib.mkDefault true;
      fonts.enable = lib.mkDefault true;
      localeChicago.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
    };
  };
}

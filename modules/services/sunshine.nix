{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.sunshine;
in
{
  options.myFeatures.programs.sunshine = {
    enable = lib.mkEnableOption "Sunshine: Open-source GameStream host";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open required ports for Sunshine in the firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    # Sunshine service configuration
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # Required for KMS screen capture on Wayland
      openFirewall = cfg.openFirewall;
    };

    # Required for controller and input emulation
    boot.kernelModules = [ "uinput" ];
    hardware.uinput.enable = true;

    # Add primary user to uinput group for input control
    users.users.apollo.extraGroups = [ "uinput" ];

    # Optional: Enable Avahi for automatic host discovery
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    # System-level dependencies for video acceleration
    environment.systemPackages = with pkgs; [
      sunshine
      vpl-gpu-rt # Required for hardware encoding on newer Intel/AMD GPUs
    ];
  };
}

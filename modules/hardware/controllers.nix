{ config, lib, pkgs, isDarwin, ... }:

let
  cfg = config.myFeatures.hardware.controllers;
in
{
  # 1. DECLARE OPTIONS (Must always exist for the evaluator)
  options.myFeatures.hardware.controllers = {
    enable = lib.mkEnableOption "Game Controller Support";
    
    xbox = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Xbox (One/Series/360) controller drivers.";
    };

    playstation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable PlayStation (DualShock/DualSense) support.";
    };

    nintendo = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nintendo Switch (Joy-Con/Pro Controller) support.";
    };
  };

  # 2. DEFINE CONFIG (Shielded from macOS)
  config = lib.mkIf cfg.enable (lib.optionalAttrs (!isDarwin) {
    hardware.xone.enable = cfg.xbox;
    hardware.xpadneo.enable = cfg.xbox;

    services.udev.extraRules = lib.mkIf cfg.playstation ''
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
    '';

    services.joycond.enable = cfg.nintendo;

    environment.systemPackages = with pkgs; [
      evtest  
      jstest-gtk 
    ] ++ lib.optional cfg.xbox pkgs.linuxConsoleConfigs;
  });
}

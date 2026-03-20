{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.controllers;
in
{
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

  config = lib.mkIf cfg.enable {
    # 1. Xbox Configuration (Phanes Parity)
    hardware.xone.enable = cfg.xbox; # Modern Xbox One/Series dongle support
    hardware.xpadneo.enable = cfg.xbox; # Better Bluetooth support for Xbox controllers

    # 2. PlayStation Configuration
    # DualSense (PS5) and DualShock 4 work best with the hid-playstation kernel driver
    services.udev.extraRules = lib.mkIf cfg.playstation ''
      # PS5 DualSense over USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
      # PS5 DualSense over Bluetooth
      KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
    '';

    # 3. Nintendo Switch Configuration
    # Uses the 'joycond' daemon to pair Joy-Cons as a single controller
    services.joycond.enable = cfg.nintendo;

    # 4. Common Packages
    # steam-run is useful for launching standalone controller calibration tools
    environment.systemPackages = with pkgs; [
      evtest      # To test if inputs are registering
      jstest-gtk  # Visual calibration tool
    ] ++ lib.optional cfg.xbox pkgs.linuxConsoleConfigs;
  };
}

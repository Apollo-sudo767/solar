# modules/hardware/input/controllers.nix
# ============================================================================
# Gamepad & Controller Subsystem (Xbox, PlayStation, Nintendo & 8BitDo)
# ============================================================================
# Configures uinput, Steam hardware udev rules, `input-remapper`, Xbox wireless
# (`xone`/`xpadneo`), Nintendo (`joycond`), DualSense hidraw permissions, and
# 8BitDo 2.4GHz/Bluetooth udev rules.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.input.controllers;
in
{
  options.myFeatures.hardware.input.controllers = {
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
    # Base input layers needed for modern controller translation layers
    hardware.uinput.enable = true;
    hardware.steam-hardware.enable = true;

    # Background remapping daemon for user-space button profiles
    services.input-remapper.enable = true;

    # Xbox wireless & Bluetooth controller drivers
    hardware.xone.enable = cfg.xbox;
    hardware.xpadneo.enable = cfg.xbox;

    # Disable Bluetooth ERTM when Xbox controllers are enabled so xpadneo pairs cleanly
    boot.extraModprobeConfig = lib.mkIf cfg.xbox ''
      options bluetooth disable_ertm=1
    '';

    # Nintendo Switch Joy-Con / Pro Controller daemon
    services.joycond.enable = cfg.nintendo;

    # Unified udev rules for PlayStation DualSense and 8BitDo controllers
    services.udev.extraRules = lib.concatStringsSep "\n" [
      (lib.optionalString cfg.playstation ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
        KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
      '')

      # Generic 8BitDo user-space access permissions (USB and Bluetooth)
      ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess"
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess"
        KERNEL=="hidraw*", KERNELS=="*2DC8:*", MODE="0666", TAG+="uaccess"
        KERNEL=="hidraw*", KERNELS=="*2dc8:*", MODE="0666", TAG+="uaccess"
      ''

      (lib.optionalString cfg.xbox ''
        # Force 8BitDo 2.4GHz Dongles and XInput modes to bind to the kernel's xpad driver
        ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3106", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 3106 > /sys/bus/usb/drivers/xpad/new_id'"
        ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="301c", MODE="0666", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 301c > /sys/bus/usb/drivers/xpad/new_id'"
        ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3109", MODE="0666", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 3109 > /sys/bus/usb/drivers/xpad/new_id'"
        ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310a", MODE="0666", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 310a > /sys/bus/usb/drivers/xpad/new_id'"
        ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310b", MODE="0666", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 310b > /sys/bus/usb/drivers/xpad/new_id'"
      '')
    ];

    environment.systemPackages =
      with pkgs;
      [
        evtest
        jstest-gtk
        input-remapper
      ]
      ++ lib.optional cfg.xbox pkgs.linuxConsoleTools;
  };
}

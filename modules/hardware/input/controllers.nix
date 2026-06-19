{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        # Base input layers needed for modern controller translation layers
        hardware.uinput.enable = true;
        hardware.steam-hardware.enable = true;

        # Xbox specific controller drivers
        hardware.xone.enable = cfg.xbox;
        hardware.xpadneo.enable = cfg.xbox;

        # Inject kernel tweaks explicitly when the xbox token is true
        boot.extraModprobeConfig = lib.mkIf cfg.xbox ''
          options bluetooth disable_ertm=1
        '';

        # PlayStation specific udev adjustments
        # Nintendo specific drivers
        services.joycond.enable = cfg.nintendo;

        # Unified udev rule management
        services.udev.extraRules = lib.concatStringsSep "\n" [
          (lib.optionalString cfg.playstation ''
            KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
            KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
          '')

          # 8BitDo Pro 3 / Modern gamepads configuration
          ''
            # Generic 8BitDo user-space access permissions
            SUBSYSTEM=="usb", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess"
            SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess"
          ''

          (lib.optionalString cfg.xbox ''
            # Force 8BitDo 2.4GHz Dongles and XInput modes to bind correctly to the kernel's xpad subsystem
            ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3106", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 3106 > /sys/bus/usb/drivers/xpad/new_id'"
            ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="301c", MODE="0666", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 301c > /sys/bus/usb/drivers/xpad/new_id'"
            ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310a", MODE="0666", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 310a > /sys/bus/usb/drivers/xpad/new_id'"
          '')
        ];

        environment.systemPackages =
          with pkgs;
          [
            evtest
            jstest-gtk
          ]
          ++ lib.optional cfg.xbox pkgs.linuxConsoleTools;
      })
    ]
  );
}

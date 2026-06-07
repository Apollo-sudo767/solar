{
  config,
  lib,
  pkgs,
  isDarwin,
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
        # Xbox specific controller drivers
        hardware.xone.enable = cfg.xbox;
        hardware.xpadneo.enable = cfg.xbox;

        # Inject kernel tweaks explicitly when the xbox token is true
        boot.extraModprobeConfig = lib.mkIf cfg.xbox ''
          options bluetooth disable_ertm=1
        '';

        # PlayStation specific udev adjustments
        services.udev.extraRules = lib.mkIf cfg.playstation ''
          KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
          KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
        '';

        # Nintendo specific drivers
        services.joycond.enable = cfg.nintendo;

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

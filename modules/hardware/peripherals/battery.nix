# modules/hardware/peripherals/battery.nix
# ============================================================================
# Laptop Power Management & ThinkPad Battery Thresholds (`auto-cpufreq` + `tpacpi-bat`)
# ============================================================================
# Configures laptop battery longevity and thermal/power efficiency:
# - Uses `auto-cpufreq` to switch automatically between `performance` (on AC)
#   and `powersave` (on battery), explicitly disabling conflicting `tlp` and
#   `power-profiles-daemon` services.
# - Sets ThinkPad battery charge start/stop thresholds via `tpacpi-bat` and
#   `acpi_call` (75%/80% by default, or 95%/100% when `fullCharge = true`).
# - Configures udev power-supply rules for Wi-Fi/Bluetooth power states and
#   systemd-logind lid switch behavior.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.peripherals.battery;

  startThreshold = if cfg.fullCharge then "95" else "75";
  stopThreshold = if cfg.fullCharge then "100" else "80";

  set-battery-thresholds = pkgs.writeShellScriptBin "set-battery-thresholds" ''
    sleep 2
    ${pkgs.tpacpi-bat}/bin/tpacpi-bat -s ST 0 ${startThreshold}
    ${pkgs.tpacpi-bat}/bin/tpacpi-bat -s SP 0 ${stopThreshold}
  '';
in
{
  options.myFeatures.hardware.peripherals.battery = {
    enable = lib.mkEnableOption "ThinkPad Power Management";
    fullCharge = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If false, caps battery charge at 80% to preserve battery longevity.";
    };
    bluetooth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Toggle Bluetooth radio power states automatically on AC vs. Battery.";
      };
    };
    aggressive = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable aggressive PCIe ASPM and kernel workqueue power-saving tweaks.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Kernel Module for ThinkPad ACPI Battery Calls
    boot.kernelModules = [ "acpi_call" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

    # 2. Automatic CPU Frequency & Governor Scaling (`auto-cpufreq`)
    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      charger = {
        governor = "performance";
        turbo = "always";
      };
      battery = {
        governor = "powersave";
        turbo = "never";
      };
    };

    # 3. ThinkPad Battery Charge Threshold Service (`tpacpi-bat`)
    systemd.services.battery-thresholds = {
      description = "Set ThinkPad battery charge thresholds";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${set-battery-thresholds}/bin/set-battery-thresholds";
        RemainAfterExit = true;
      };
    };

    # 4. Prevent Conflicts with Competing Power Daemons & Configure Deep Sleep
    services.tlp.enable = lib.mkForce false;
    services.power-profiles-daemon.enable = lib.mkForce false;

    boot.kernelParams = [
      "mem_sleep_default=deep"
    ]
    ++ (lib.optionals cfg.aggressive [
      "pcie_aspm=force"
      "workqueue.power_efficient=Y"
      "nvme.noacpi=1"
    ]);

    # 5. Radio & Network Power Saving Rules
    networking.networkmanager.wifi.powersave = true;
    hardware.bluetooth.powerOnBoot = lib.mkIf cfg.bluetooth.enable false;

    services.udev.extraRules = ''
      # ON AC: Max performance, Radio ON
      SUBSYSTEM=="power_supply", ATTR{online}=="1", \
        RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save off", \
        ${lib.optionalString cfg.bluetooth.enable "RUN+=\"${pkgs.bluez}/bin/bluetoothctl power on\", \\"}
        RUN+="${pkgs.networkmanager}/bin/nmcli radio wifi on"

      # ON BATTERY: Power save Radio
      SUBSYSTEM=="power_supply", ATTR{online}=="0", \
        RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save on" ${lib.optionalString cfg.bluetooth.enable ", \\"}
        ${lib.optionalString cfg.bluetooth.enable "RUN+=\"${pkgs.bluez}/bin/bluetoothctl power off\""}
    '';

    # 6. Laptop Lid Switch & Suspend Behavior
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
      LidSwitchIgnoreInhibited = "yes";
    };

    # 7. Power Diagnostic & Threshold Utilities (`bluez` is provided by `bluetooth.nix`)
    environment.systemPackages = with pkgs; [
      tpacpi-bat
      powertop
      acpi
      iw
    ];
  };
}

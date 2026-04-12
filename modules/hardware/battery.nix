{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.battery;
  
  # Define thresholds as strings to ensure clean interpolation
  startThreshold = if cfg.fullCharge then "95" else "75";
  stopThreshold = if cfg.fullCharge then "100" else "80";

  # Battery threshold script for T14 Gen 2 hardware registers
  set-battery-thresholds = pkgs.writeShellScriptBin "set-battery-thresholds" ''
    # Wait a moment for acpi_call to be fully initialized
    sleep 2
    # BAT0 is the internal battery
    # -s ST (Start Threshold), -s SP (Stop Threshold)
    ${pkgs.tpacpi-bat}/bin/tpacpi-bat -s ST 0 ${startThreshold}
    ${pkgs.tpacpi-bat}/bin/tpacpi-bat -s SP 0 ${stopThreshold}
  '';
in
{
  # --- OPTIONS ---
  options.myFeatures.hardware.battery = {
    enable = lib.mkEnableOption "ThinkPad Power Management";
    fullCharge = lib.mkOption { 
      type = lib.types.bool; 
      default = false;
      description = "If false, caps charge at 80% to preserve battery health.";
    };
    bluetooth = { 
      enable = lib.mkOption { 
        type = lib.types.bool;
        default = false; 
        description = "Manage Bluetooth power states based on AC/Battery.";
      }; 
    };
    aggressive = lib.mkOption { 
      type = lib.types.bool; 
      default = false;
      description = "Enable experimental kernel tweaks for maximum savings.";
    };
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    # 0. Kernel Requirements
    # Required backend for tpacpi-bat to talk to ThinkPad hardware registers
    boot.kernelModules = [ "acpi_call" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

    # 1. CPU Management
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

    # 2. Battery Thresholds (Manual hardware sets)
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

    # 3. Explicit Hardware Control & Conflict Resolution
    services.tlp.enable = lib.mkForce false;
    services.power-profiles-daemon.enable = lib.mkForce false;

    boot.kernelParams = [ 
      "mem_sleep_default=deep"
      "usbcore.autosuspend=-1"
    ] ++ (lib.optionals cfg.aggressive [
      "pcie_aspm=force"
      "workqueue.power_efficient=Y" 
      "nvme.noacpi=1"
    ]);

    # 4. Radio & Networking
    networking.networkmanager.wifi.powersave = true;
    hardware.bluetooth.powerOnBoot = lib.mkIf cfg.bluetooth.enable false;

    services.udev.extraRules = ''
      # ON AC: Max performance, Bluetooth ON
      SUBSYSTEM=="power_supply", ATTR{online}=="1", \
        RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save off", \
        RUN+="${pkgs.bluez}/bin/bluetoothctl power on", \
        RUN+="${pkgs.networkmanager}/bin/nmcli radio wifi on"

      # ON BATTERY: Power save Wifi, Bluetooth OFF
      SUBSYSTEM=="power_supply", ATTR{online}=="0", \
        RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save on", \
        RUN+="${pkgs.bluez}/bin/bluetoothctl power off"
    '';

    # 5. Sleep Stability
    services.logind = {
      settings.Login.HandleLidSwitch = "suspend";
      settings.Login.HandleLidSwitchExternalPower = "lock";
    };

    # 6. System Packages
    environment.systemPackages = with pkgs; [
      tpacpi-bat
      powertop
      acpi
      iw
      bluez
    ];
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.battery;

  # Battery threshold script for T14 Gen 2 hardware registers
  set-battery-thresholds = pkgs.writeShellScriptBin "set-battery-thresholds" ''
    # BAT0 is the internal battery
    ${pkgs.tpacpi-bat}/bin/tpacpi-bat -s ST 0 ${if cfg.fullCharge then "95" else "75"}
    ${pkgs.tpacpi-bat}/bin/tpacpi-bat -s SP 0 ${if cfg.fullCharge then "100" else "80"}
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
    # 1. CPU Management
    # auto-cpufreq handles dynamic scaling better than TLP on modern Ryzen/Intel
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
    # We use mkForce to ensure these stay OFF even if other modules try to enable them
    services.tlp.enable = lib.mkForce false;
    services.power-profiles-daemon.enable = lib.mkForce false;

    boot.kernelParams = [ 
      "mem_sleep_default=deep"   # Ensure ports/logic power off completely during sleep
      "usbcore.autosuspend=-1"   # Prevent USB idling while the system is awake
    ] ++ (lib.optionals cfg.aggressive [
      "pcie_aspm=force"           # Force PCIe lanes to sleep
      "workqueue.power_efficient=Y" 
      "nvme.noacpi=1"             # Deep sleep for NVME SSDs
    ]);

    # 4. Radio & Networking
    networking.networkmanager.wifi.powersave = true;
    hardware.bluetooth.powerOnBoot = lib.mkIf cfg.bluetooth.enable false;

    # udev: Manual control over Radio and Wifi power states
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
      lidSwitch = "suspend";
      lidSwitchExternalPower = "lock";
    };

    # 6. System Packages
    environment.systemPackages = with pkgs; [
      tpacpi-bat  # Backend for thresholds
      powertop    # Power monitoring
      acpi        # Battery status
      iw          # Wifi power control
      bluez       # Bluetooth control
    ];
  };
}

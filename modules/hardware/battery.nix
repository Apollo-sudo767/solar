{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.hardware.battery;

  # Nix-native script to toggle Bluetooth (only included if bluetooth.enable is true)
  toggle-bt = pkgs.writeShellScriptBin "toggle-bt" ''
    if bluetoothctl show | grep -q "Powered: yes"; then
      ${pkgs.bluez}/bin/bluetoothctl power off
      ${pkgs.libnotify}/bin/notify-send "Bluetooth" "Powered Off" -i bluetooth-disabled
    else
      ${pkgs.bluez}/bin/bluetoothctl power on
      ${pkgs.libnotify}/bin/notify-send "Bluetooth" "Powered On" -i bluetooth
    fi
  '';
in
{
  # --- OPTIONS ---
  options.myFeatures.hardware.battery = {
    enable = lib.mkEnableOption "ThinkPad Battery & Power Management";
    
    fullCharge = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If false, caps charge at 80% to preserve battery health.";
    };

    bluetooth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Start Bluetooth OFF on boot and enable AC plug-in automation.";
      };
    };

    aggressive = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable experimental kernel tweaks (ASPM/NVME) for maximum savings.";
    };
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    # 1. CPU Management (The Brain)
    # auto-cpufreq is dynamic and better for modern Ryzen/Intel scaling
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

    # 2. TLP Management (The Body & Battery Health)
    services.tlp = {
      enable = true;
      settings = {
        # CRITICAL: We block TLP from touching the CPU so it doesn't fight auto-cpufreq
        CPU_SCALING_GOVERNOR_ON_AC = lib.mkForce null;
        CPU_SCALING_GOVERNOR_ON_BAT = lib.mkForce null;
        CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkForce null;
        CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce null;

        # Battery Charge Thresholds
        START_CHARGE_THRESH_BAT0 = if cfg.fullCharge then 95 else 75;
        STOP_CHARGE_THRESH_BAT0 = if cfg.fullCharge then 100 else 80;

        # Platform Profiles (T14/P1 specific cooling/power)
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # General Hardware Power Saving
        USB_AUTOSUSPEND = 1;
        WIFI_PWR_ON_BAT = "on";
      };
    };

    # 3. Connectivity Logic
    networking.networkmanager.wifi.powersave = true;
    hardware.bluetooth.powerOnBoot = lib.mkIf cfg.bluetooth.enable false;

    # udev: Automatically "Wake Up" Bluetooth/Wifi when you plug in the charger
    services.udev.extraRules = lib.mkIf cfg.bluetooth.enable ''
      SUBSYSTEM=="power_supply", ATTR{online}=="1", \
        RUN+="${pkgs.bluez}/bin/bluetoothctl power on", \
        RUN+="${pkgs.networkmanager}/bin/nmcli radio wifi on"
    '';

    # 4. Aggressive Hardware Tweaks (Sub-option)
    boot.kernelParams = lib.mkIf cfg.aggressive [
      "pcie_aspm=force"           # Forces PCIe lanes to go to sleep
      "workqueue.power_efficient=Y" 
      "nvme.noacpi=1"             # Helps modern SSDs enter deep sleep
    ];

    # 5. Conflict Resolution & Sleep Stability
    services.power-profiles-daemon.enable = false;
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "lock";
    };

    # 6. System Packages
    environment.systemPackages = with pkgs; [
      tpacpi-bat  # ThinkPad specific battery control
      powertop    # For monitoring wattage
      blueman     # Bluetooth GUI
      libnotify   # For toggle-bt notifications
    ] ++ (lib.optional cfg.bluetooth.enable toggle-bt);
  };
}

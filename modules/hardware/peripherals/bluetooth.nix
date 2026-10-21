# modules/hardware/peripherals/bluetooth.nix
# ============================================================================
# Bluetooth Stack, Blueman Applet & Low-Latency Gaming Profile
# ============================================================================
# Configures BlueZ (`hardware.bluetooth`) with experimental battery reporting,
# disables USB autosuspend on `btusb` adapters so controllers don't drop out,
# persists `/var/lib/bluetooth` pairing keys across ephemeral reboots, and
# optionally applies low-latency BLE connection intervals (`gaming.enable = true`).
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.peripherals.bluetooth;
  isLaptopBattery = config.myFeatures.hardware.peripherals.battery.enable or false;
  enabled = cfg.enable || cfg.gaming.enable;
in
{
  options.myFeatures.hardware.peripherals.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth hardware & Blueman service";
    gaming = {
      enable = lib.mkEnableOption "Low-latency Bluetooth connection parameters for gaming desktops";
    };
  };

  config = lib.mkIf enabled {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = lib.mkDefault true;
      settings = {
        General = {
          # Required for accurate gamepad battery reporting and modern BLE peripheral profiles
          Experimental = true;
          # Ensures predictable handshaking with modern Bluetooth devices
          Privacy = "device";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
      usbutils # Provides `lsusb` for inspecting USB Bluetooth controllers
      pciutils # Provides `lspci` for inspecting PCIe wireless cards
    ];

    # Prevent USB autosuspend from disconnecting Bluetooth receivers mid-session.
    # Low-latency PCIe ASPM disable (`pcie_aspm=off`) is only applied when
    # `gaming.enable = true` on non-battery desktop hosts so laptop battery life
    # (`battery.nix`) is never compromised.
    boot.kernelParams = [
      "usbcore.autosuspend=-1"
    ]
    ++ lib.optionals (cfg.gaming.enable && !isLaptopBattery) [
      "iommu=pt"
      "pcie_aspm=off"
    ];

    boot.extraModprobeConfig = ''
      options btusb enable_autosuspend=n reset=1
    '';

    services.blueman.enable = true;

    # Tighten Bluetooth HCI connection intervals (7.5ms) when gaming mode is enabled
    systemd.tmpfiles.rules = lib.mkIf cfg.gaming.enable [
      "w /sys/kernel/debug/bluetooth/hci0/conn_min_interval - - - - 6"
      "w /sys/kernel/debug/bluetooth/hci0/conn_max_interval - - - - 6"
    ];

    # Persist paired device keys across reboots on ephemeral-root hosts
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          directories = [ "/var/lib/bluetooth" ];
        };
  };
}

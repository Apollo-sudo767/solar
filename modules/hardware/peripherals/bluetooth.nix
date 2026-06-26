{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.hardware.peripherals.bluetooth;
  enabled = cfg.enable || cfg.gaming.enable;
in
{
  options.myFeatures.hardware.peripherals.bluetooth = {
    enable = lib.mkEnableOption "Enables bluetooth services";
    gaming = {
      enable = lib.mkEnableOption "Force low-latency Bluetooth connection parameters for gaming";
    };
  };

  config = lib.mkIf enabled (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        hardware.bluetooth = {
          enable = true;
          powerOnBoot = lib.mkDefault true;
          settings = {
            General = {
              # Required for accurate gamepad battery tracking and peripheral profiles
              Experimental = true;
              # Ensures predictable hands-shaking with modern devices
              Privacy = "device";
            };
          };
        };

        environment.systemPackages = with pkgs; [
          bluez
          bluez-tools
          usbutils # Injects 'lsusb' natively into your deployment environment
          pciutils # Injects 'lspci' natively into your deployment environment
        ];

        boot.kernelParams = [
          "usbcore.autosuspend=-1"
          "iommu=pt"
          "pcie_aspm=off"
        ];
        boot.extraModprobeConfig = ''
          options btusb enable_autosuspend=n reset=1
        '';

        services.blueman.enable = true;

        systemd.tmpfiles.rules = lib.mkIf cfg.gaming.enable [
          "w /sys/kernel/debug/bluetooth/hci0/conn_min_interval - - - - 6"
          "w /sys/kernel/debug/bluetooth/hci0/conn_max_interval - - - - 6"
        ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [ "/var/lib/bluetooth" ];
            };
      })
    ]
  );
}

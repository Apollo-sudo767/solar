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
in
{
  options.myFeatures.hardware.peripherals.bluetooth = {
    enable = lib.mkEnableOption "Enables bluetooth services";
  };

  config = lib.mkIf cfg.enable (
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

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [ "/var/lib/bluetooth" ];
            };
      })
    ]
  );
}

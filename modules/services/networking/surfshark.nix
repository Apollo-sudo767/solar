{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.services.networking.surfshark;
  progCfg = config.myFeatures.programs.utilities.surfshark;
  flatpakCfg = config.myFeatures.services.system.flatpak.surfshark;

  enabled = cfg.enable || (progCfg.enable or false) || (flatpakCfg.enable or false);
in
{
  options = {
    myFeatures.services.networking.surfshark = {
      enable = lib.mkEnableOption "Surfshark VPN client (via Flatpak on Linux, Homebrew Cask on macOS)";
    };

    # Backwards compatibility and convenience aliases
    myFeatures.programs.utilities.surfshark = {
      enable = lib.mkEnableOption "Surfshark VPN (alias for services.networking.surfshark)";
    };
    myFeatures.services.system.flatpak.surfshark = {
      enable = lib.mkEnableOption "Surfshark VPN via Flatpak (alias for services.networking.surfshark)";
    };
  };

  config = lib.mkIf enabled (
    lib.mkMerge [
      # 1. Linux configuration (Flatpak declarative installation via nix-flatpak)
      (lib.optionalAttrs (!isDarwin) {
        # Ensure Flatpak support is enabled
        myFeatures.services.system.flatpak.enable = lib.mkDefault true;

        # Declarative package installation via nix-flatpak
        services.flatpak.packages = [
          "com.surfshark.Surfshark"
        ];

        # Convenience CLI launcher wrapper
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "surfshark" ''
            exec flatpak run com.surfshark.Surfshark "$@"
          '')
        ];

        # Preservation of Surfshark configuration and credentials on ephemeral root
        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
                  ".var/app/com.surfshark.Surfshark"
                  ".config/Surfshark"
                ];
              });
            };
      })

      # 2. macOS configuration (Homebrew Cask)
      (lib.optionalAttrs isDarwin {
        homebrew.casks = [ "surfshark" ];
      })
    ]
  );
}

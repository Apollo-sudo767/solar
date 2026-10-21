# modules/services/networking/surfshark.nix
# ============================================================================
# Surfshark VPN Client
# ============================================================================
# Cross-platform Surfshark VPN client:
# - On Linux: Installed declaratively via nix-flatpak (`com.surfshark.Surfshark`)
#   with a `surfshark` CLI wrapper. Flatpak `.var` state is preserved globally
#   by `modules/services/system/flatpak.nix`, while `~/.config/Surfshark` is
#   preserved here.
# - On macOS: Installed via Homebrew Cask.
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.services.networking.surfshark;
in
{
  options.myFeatures.services.networking.surfshark = {
    enable = lib.mkEnableOption "Surfshark VPN client (via Flatpak on Linux, Homebrew Cask on macOS)";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. Linux configuration (Flatpak declarative installation via nix-flatpak)
      (lib.optionalAttrs (!isDarwin) {
        # Ensure Flatpak support is enabled (which also preserves ~/.var)
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

        # Preservation of native Surfshark configuration on ephemeral root
        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
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

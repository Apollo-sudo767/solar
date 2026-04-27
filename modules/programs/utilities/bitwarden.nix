{
  config,
  lib,
  pkgs,
  ...
}: # Added pkgs.stdenv.isDarwin

let
  cfg = config.myFeatures.programs.utilities.bitwarden;
in
{
  options.myFeatures.programs.utilities.bitwarden.enable = lib.mkEnableOption "Bitwarden Stack";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages =
          with pkgs;
          [
            bitwarden-desktop
            bitwarden-cli
            # pinentry-gnome3 is Linux-specific; on Mac, rbw can use native pinentry
          ]
          ++ lib.optional (!pkgs.stdenv.isDarwin) pinentry-gnome3;

        # Home Manager configuration works on both macOS and NixOS
        home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
          programs.rbw = {
            enable = true;
            settings = {
              email = "fireshifter767@gmail.com";
              # Only use gnome3 pinentry if on Linux
              pinentry = pkgs.pinentry-gnome3;
            };
          };
          home.packages = [ pkgs.bitwarden-desktop ];
        });
      }

      # Shield Linux-only system services
      {
        services.dbus.enable = true;
        security.polkit.enable = true;
      }
    ]
  );
}

{ config, lib, pkgs, isDarwin, ... }: # Added isDarwin

let
  cfg = config.myFeatures.programs.bitwarden;
in
{
  options.myFeatures.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden Stack";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        bitwarden-desktop
        bitwarden-cli
        # pinentry-gnome3 is Linux-specific; on Mac, rbw can use native pinentry
      ] ++ lib.optional (!isDarwin) pinentry-gnome3;

      # Home Manager configuration works on both macOS and NixOS
      home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
        programs.rbw = {
          enable = true;
          settings = {
            email = "fireshifter767@gmail.com";
            # Only use gnome3 pinentry if on Linux
            pinentry = if isDarwin then null else pkgs.pinentry-gnome3;
          };
        };
        home.packages = [ pkgs.bitwarden-desktop ];
      });
    }

    # Shield Linux-only system services
    (lib.optionalAttrs (!isDarwin) {
      services.dbus.enable = true;
      security.polkit.enable = true;
    })
  ]);
}

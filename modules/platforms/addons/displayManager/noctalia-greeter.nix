# modules/platforms/addons/displayManager/noctalia-greeter.nix
#
# Configures the Noctalia display manager greeter, Stylix wallpaper integration,
# and AccountsService user profile icons on NixOS.
{
  config,
  lib,
  pkgs,
  isDarwin,
  isStable ? false,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
  inherit (config.myFeatures.core.system.users) usernames;
  apolloIcon = ../../../../assets/icons/Apollo.jpg;
in
{
  # `services.displayManager.noctalia-greeter` only exists in nixpkgs-unstable.
  config = lib.mkIf (cfg.manager == "noctalia-greeter") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin && !isStable) {
        services.displayManager.noctalia-greeter = {
          enable = true;
          settings = {
            cursor.size = 24;
            keyboard.layout = "us";
            appearance.wallpaper.path =
              if (config.stylix.enable or false) && (config.stylix.image or null) != null then
                "${config.stylix.image}"
              else
                "${../../../../assets/wallpapers/space.png}";
            output.name = "DP-2";
          };
          cursorTheme = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
          };
        };
        systemd.tmpfiles.settings."10-noctalia-greeter-icons" =
          lib.optionalAttrs (lib.elem "apollo" usernames)
            {
              "/var/lib/AccountsService/icons/apollo"."L+" = {
                argument = "${apolloIcon}";
              };
              "/var/lib/AccountsService/users/apollo"."f+" = {
                mode = "0600";
                user = "root";
                group = "root";
                argument = ''
                  [User]
                  Icon=/var/lib/AccountsService/icons/apollo
                '';
              };
            };
      })
    ]
  );
}

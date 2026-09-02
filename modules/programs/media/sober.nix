{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.sober;
  flatpakCfg = config.myFeatures.services.system.flatpak.sober;
  enabled = cfg.enable || (flatpakCfg.enable or false);
in
{
  options = {
    myFeatures.programs.media.sober = {
      enable = lib.mkEnableOption "Sober (Roblox) via Flatpak";
    };
    myFeatures.services.system.flatpak.sober = {
      enable = lib.mkEnableOption "Sober (Roblox) via Flatpak";
    };
  };

  config = lib.mkIf enabled {
    # Ensure Flatpak support is enabled
    myFeatures.services.system.flatpak.enable = lib.mkDefault true;

    # Declarative package installation via nix-flatpak
    services.flatpak.packages = [
      "org.vinegarhq.Sober"
    ];

    # Convenience CLI launcher wrapper
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "sober" ''
        exec flatpak run org.vinegarhq.Sober "$@"
      '')
    ];

    # State preservation for Sober
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".var/app/org.vinegarhq.Sober"
            ];
          });
        };
  };
}

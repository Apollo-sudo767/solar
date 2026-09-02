{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.roblox;
  soberCfg = config.myFeatures.programs.media.sober;
  flatpakSoberCfg = config.myFeatures.services.system.flatpak.sober;

  enabled =
    cfg.enable || cfg.sober.enable || (soberCfg.enable or false) || (flatpakSoberCfg.enable or false);
in
{
  options = {
    myFeatures.programs.media.roblox = {
      enable = lib.mkEnableOption "Roblox Suite (Sober via Flatpak)";
      sober = {
        enable = lib.mkEnableOption "Sober (Roblox runtime via Flatpak)";
      };
    };

    # Backwards compatibility and convenience aliases
    myFeatures.programs.media.sober = {
      enable = lib.mkEnableOption "Sober (alias for roblox.sober)";
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

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.gaming;
in
{
  options.myFeatures.programs.media.gaming = {
    enable = lib.mkEnableOption "Gaming Suite";
    prism.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Prism Launcher with Java 21 (ZGC ready)";
    };
    steam.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Steam and gaming performance tools";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Prism Launcher Module
      (lib.mkIf cfg.prism.enable {
        environment.systemPackages = [
          # This overrides Prism's internal wrapper to ensure Java 21 is visible
          (pkgs.prismlauncher.override {
            jdks = [ pkgs.temurin-bin-21 ];
          })
        ];
      })

      # Steam Module
      (lib.mkIf cfg.steam.enable {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true; # Useful if you host local test servers
        };

        environment.systemPackages = with pkgs; [
          mangohud
          gamemode
          libkrb5
          keyutils
        ];
      })
    ]
  );
}

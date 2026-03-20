{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.boot;
  # Points to your assets folder relative to this file
  wallpaper = ../../assets/wallpapers/limine-bg.png;
in
{
  options.myFeatures.core.boot = {
    enable = lib.mkEnableOption "Limine Bootloader";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };
  };
}

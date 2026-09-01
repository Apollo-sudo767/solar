{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.dwm;
in
{
  options.myFeatures.platforms.desktops.dwm = {
    enable = lib.mkEnableOption "DWM (Suckless Dynamic X11 Tiling Window Manager)";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager.dwm.enable = true;
    };

    environment.systemPackages = with pkgs; [
      dmenu
      slstatus
      feh
      picom
      xclip
      libnotify
      brightnessctl
    ];
  };
}

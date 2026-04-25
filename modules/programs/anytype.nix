{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.anytype;
in
{
  options.myFeatures.programs.anytype.enable = lib.mkEnableOption "Anytype";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { environment.systemPackages = [ pkgs.anytype ]; }

    # Shield the Systemd service from macOS
    {
      systemd.user.services.anytype-desktop-fix = {
        description = "Prevent Anytype from creating a conflicting local desktop file";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p %h/.local/share/applications && ln -sf /dev/null %h/.local/share/applications/anytype.desktop'";
          RemainAfterExit = true;
        };
      };
    }
  ]);
}

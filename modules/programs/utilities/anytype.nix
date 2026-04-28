{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  inherit isDarwin isTotal;
  cfg = config.myFeatures.programs.utilities.anytype;
in
{
  options.myFeatures.programs.utilities.anytype.enable = lib.mkEnableOption "Anytype";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { environment.systemPackages = [ pkgs.anytype ]; }

      # Shield the Systemd service from macOS
      (lib.optionalAttrs (!isDarwin) {
        systemd.user.services.anytype-desktop-fix = {
          description = "Prevent Anytype from creating a conflicting local desktop file";
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p %h/.local/share/applications && ln -sf /dev/null %h/.local/share/applications/anytype.desktop'";
            RemainAfterExit = true;
          };
        };
      })
    ]
  );
}

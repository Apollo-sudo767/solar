{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swww;
  inherit (config.myFeatures.core.system.users) usernames;
in
{
  options.myFeatures.platforms.addons.swww.enable = lib.mkEnableOption "swww wallpaper daemon";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.awww ];

    home-manager.users = lib.genAttrs usernames (
      _name:
      (lib.optionalAttrs (!isDarwin) {
        # swww (now awww) doesn't have a direct home-manager module in nixpkgs yet,
        # but we can manage its service or just let it be started by the WM.
        systemd.user.services.swww = {
          Unit = {
            Description = "awww wallpaper daemon";
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.awww}/bin/awww-daemon";
            ExecStartPost = "${pkgs.awww}/bin/awww img ${config.stylix.image}";
            Restart = "on-failure";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      })
    );
  };
}

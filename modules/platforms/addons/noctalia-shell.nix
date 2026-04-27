{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.noctalia-shell;
  usernames = lib.filter (n: n != "enable" && n != "usernames") config.myFeatures.core.system.users.usernames;
in
{
  options.myFeatures.platforms.addons.noctalia-shell.enable = lib.mkEnableOption "Noctalia Shell (Wayland Shell)";

  config = lib.mkIf (cfg.enable && !isDarwin) {
    # Install the package globally
    environment.systemPackages = [ pkgs.noctalia-shell ];

    # Required services for Noctalia's status modules
    services.upower.enable = lib.mkDefault true;

    home-manager.users = lib.genAttrs usernames (name: {
      # Install to user profile as well for home-manager context
      home.packages = [ pkgs.noctalia-shell ];

      systemd.user.services.noctalia-shell = {
        Unit = {
          Description = "Noctalia Shell";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    });
  };
}

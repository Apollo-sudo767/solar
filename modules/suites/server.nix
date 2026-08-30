{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.server;
in
{
  options.myFeatures.suites.server = {
    enable = lib.mkEnableOption "Server Suite (Headless, Hardened SSH, Tailscale, Automated maintenance)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      core = {
        security = {
          ssh.enable = lib.mkDefault true;
          security.enable = lib.mkDefault true;
        };
        shell = {
          cli.enable = lib.mkDefault true;
          shell.enable = lib.mkDefault true;
          shell-branch.enable = lib.mkDefault true;
        };
        nix = {
          automation.enable = lib.mkDefault true;
          lix.enable = lib.mkDefault true;
        };
      };

      services = {
        networking.tailscale.enable = lib.mkDefault true;
        hardware.udisks2.enable = lib.mkDefault true;
      };
    };
  };
}

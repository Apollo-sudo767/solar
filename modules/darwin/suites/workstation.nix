{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.suites.darwinWorkstation;
in
{
  options.myFeatures.suites.darwinWorkstation = {
    enable = lib.mkEnableOption "Darwin (macOS) Workstation Suite";
  };

  config = lib.mkIf (cfg.enable && isDarwin) {
    myFeatures = {
      core.shell = {
        cli.enable = lib.mkDefault true;
        shell.enable = lib.mkDefault true;
      };

      darwin.system = {
        core.enable = lib.mkDefault true;
        homebrew.enable = lib.mkDefault true;
      };

      programs = {
        terminal = {
          helix.enable = lib.mkDefault true;
          fastfetch.enable = lib.mkDefault true;
          antigravity.enable = lib.mkDefault true;
          direnv.enable = lib.mkDefault true;
        };

        utilities.filemanager.enable = lib.mkDefault true;
        office.ap-office.enable = lib.mkDefault true;
      };
    };
  };
}

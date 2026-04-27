{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.core.shell.cli;
in
{
  options.myFeatures.core.shell.cli.enable = lib.mkEnableOption "Standard CLI tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        # --- Cross-Platform Tools (Mac & Linux) ---
        git
        helix
        btop
        eza
        fzf
        fd
        ripgrep
        wget
        curl
        fastfetch
        tree
        jq
        nurl
        comma
      ]
      ++ (lib.optionals (!pkgs.stdenv.isDarwin) [
        # --- Linux-Only Tools ---
        lm_sensors
        sysstat
      ]);

    environment.variables.EDITOR = "hx";
    environment.variables.VISUAL = "hx";
  };
}

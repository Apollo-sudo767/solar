{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.ssh;
in
{
  options.myFeatures.core.ssh = {
    enable = lib.mkEnableOption "SSH Service";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # 1. Common configuration for both Mac and Linux
    {
      services.openssh.enable = true;
    }

    # 2. Linux-only configuration (Shielded from the Mac Evaluator)
    {
      services.openssh.settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    }
  ]);
}

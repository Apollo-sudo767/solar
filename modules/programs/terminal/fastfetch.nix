{
  config,
  lib,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.fastfetch;
  userList = config.myFeatures.core.system.users.usernames;
in
{
  options.myFeatures.programs.terminal.fastfetch = {
    enable = lib.mkEnableOption "fastfetch system info fetcher";
    logoType = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "kitty"
        "sixel"
        "chafa"
        "ascii"
      ];
      default = "auto";
      description = "Logo rendering backend.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs userList (_name: {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            source = "nixos";
            type = cfg.logoType;
            width = 24;
            height = 12;
            padding = {
              top = 2;
              left = 2;
              right = 2;
            };
          };
        };
      };
    });
  };
}

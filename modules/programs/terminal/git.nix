{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.git;
in
{
  options.myFeatures.programs.terminal.git = {
    enable = lib.mkEnableOption "Git Configuration";
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Apollo-sudo767";
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "fireshifter767@gmail.com";
      description = "Git user email";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
        };
      };
    });
  };
}

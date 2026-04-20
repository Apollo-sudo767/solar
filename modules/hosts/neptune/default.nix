{ lib, pkgs, ...}:

{
  # Darwin specific system settings
  system.stateVersion = 5;
  
  myFeatures = {
    core.enable = true;
    shell.enable = true;
    
    # 1. Matching Background & Theme from Mars
    systems = {
      presets.gruvboxNiri.enable = true;
    };

    programs = {
      ghostty.enable = true;
      fastfetch.enable = true;
      helix.enable = true;
    };

    # 2. Add Tailscale
    services.tailscale.enable = true;
  };

  # macOS-specific system configuration
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
  };
  
  users.users.apollo = {
    name = "apollo";
    home = "/Users/apollo";
  };
}

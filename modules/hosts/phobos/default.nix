{
  meta = {
    system = "aarch64-darwin"; 
    stable = false;
  };

  module = { pkgs, ... }: {
    system.stateVersion = 5; 

    myFeatures = {
      # --- Enable your cross-platform modules ---
      core.enable = true;
      shell.enable = true;
      programs = {
        ghostty.enable = true;
        helix.enable = true;
        fastfetch.enable = true;
      };

      # --- Enable your NEW macOS-specific module ---
      darwin.core.enable = true;
    };
  };
}

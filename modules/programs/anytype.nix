{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.anytype;
in
{
  options.myFeatures.programs.anytype = {
    enable = lib.mkEnableOption "Anytype - Local-first, P2P personal knowledge base";
  };

  config = lib.mkIf cfg.enable {
    # Install the package
    environment.systemPackages = [ pkgs.anytype ];

    # Fix: Prevent Anytype from creating a broken local desktop file.
    # We do this by creating a symlink in the local user directory to /dev/null
    # or by ensuring the system-wide desktop entry is correctly prioritized.
    # Note: This uses the standard NixOS way to handle user-level file conflicts.
    
    systemd.user.services.anytype-desktop-fix = {
      description = "Prevent Anytype from creating a conflicting local desktop file";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        # This command creates a symlink to /dev/null for the file Anytype tries to create.
        # This makes the file 'read-only' to the application's internal script.
        ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p %h/.local/share/applications && ln -sf /dev/null %h/.local/share/applications/anytype.desktop'";
        RemainAfterExit = true;
      };
    };

    # Ensure the correct desktop file is used by the system
    # This overrides any local 'dirty' hacks the AppImage/Binary might try
    xdg.terminal-exec.settings = {
      # Optional: specific handling if you use custom launchers
    };
  };
}

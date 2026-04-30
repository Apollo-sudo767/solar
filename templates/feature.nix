{
  # 1. META BLOCK (The "Peek" Layer)
  # This allows the flake to see the system type without evaluating the whole module.
  meta = {
    system = "x86_64-linux"; # Standard for Mars/Europa. Use "aarch64-darwin" for Phobos.
    stable = false; # Toggle for tracking unstable vs stable channels.
  };

  # 2. MODULE BLOCK
  module =
    {
      config,
      lib,
      pkgs,
      inputs,
      isDarwin,
      ...
    }:
    let
      # Shortcut for your feature configuration
      cfg = config.myFeatures.template;
    in
    {
      # 3. IMPORTS (OS-Aware)
      # Only import Linux-specific hardware or service modules if we aren't on Darwin.
      imports = lib.optional (!isDarwin) inputs.nix-minecraft.nixosModules.minecraft-servers;

      # 4. OPTIONS (The Toggle Board)
      options.myFeatures.template = {
        enable = lib.mkEnableOption "Master Learning Template";

        # NEGATIVE TOGGLE: This is ON by default if 'template.enable' is true.
        # Useful for core features you want to opt-out of rather than opt-in.
        defaultFeature = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "A feature that stays on unless you explicitly set it to false.";
        };

        # STANDARD TOGGLE: Classic opt-in feature.
        optionalExtra = lib.mkEnableOption "An optional addon feature";
      };

      # 5. CONFIG (The Logic Layer)
      config = lib.mkIf cfg.enable {

        # SHARED CONFIGURATION (Mac & Linux)
        # ---------------------------------
        environment.systemPackages =
          with pkgs;
          [
            helix
            git
          ]
          ++ lib.optionals cfg.optionalExtra [ pkgs.ripgrep ];

        # DARWIN-SPECIFIC CONFIGURATION
        # -----------------------------
        # This block only executes on Phobos.
        stdenv.hostPlatform.system.defaults = lib.mkIf isDarwin {
          dock.autohide = true;
        };

        # NIXOS-SPECIFIC CONFIGURATION (The "Shield")
        # ------------------------------------------
        # Use lib.optionalAttrs or lib.mkIf (!isDarwin) to prevent Mac build errors.
        # Perfect for systemd, firewall, or nix-minecraft.
        networking.firewall = lib.mkIf (!isDarwin) {
          allowedTCPPorts = [ 8080 ];
        };

        # Example of sllv.nix style systemd override [cite: 51]
        systemd.services.example-service = lib.mkIf (!isDarwin) {
          serviceConfig.TimeoutStopSec = lib.mkForce "120s";
        };

        # HOME MANAGER (Cross-Platform via Stylix)
        # ----------------------------------------
        # Stylix automatically bridges the gap between NixOS and Darwin apps.
        stylix.targets.helix.enable = true;
      };
    };
}

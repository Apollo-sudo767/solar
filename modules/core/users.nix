{ config, lib, pkgs, ... }:

{
  config = {
    # This maps over every user you defined in the host file
    users.users = lib.mapAttrs (name: userOpts: {
      isNormalUser = true;
      shell = pkgs.zsh;
      
      # Group Logic: Trusted users get 'wheel' (sudo)
      extraGroups = [ "networkmanager" "video" "audio" ]
        ++ (if userOpts.isTrusted then [ "wheel" "docker" "libvirtd" ] else [ ])
        ++ (userOpts.extraGroups or [ ]);

      # Sops-nix integration: Looks for 'nova_password' or 'lyra_password'
      hashedPasswordFile = config.sops.secrets."${name}_password".path;
    }) config.myFeatures.users;

    # Ensure every user gets their own Home Manager environment automatically
    # This is handled by your "Double-Agent" scanner in modules/default.nix
  };
}

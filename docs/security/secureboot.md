# Native Secure Boot with Limine 🛡️

Secure Boot ensures that only cryptographically signed kernels and EFI bootloaders can execute on the hardware, preventing evil-maid attacks and unauthorized boot modifications.

______________________________________________________________________

## 🚀 Setup Guide with `sbctl`

### Step 1: Put UEFI Firmware into Setup Mode

1. Reboot the machine and enter your motherboard's UEFI/BIOS settings (usually `Del`, `F2`, or `F12`).
1. Navigate to the **Secure Boot** settings.
1. Select **Clear Secure Boot Keys** or **Enter Setup Mode** (this puts the firmware in "Setup Mode" allowing custom key enrollment).
1. Save and reboot into NixOS.

______________________________________________________________________

### Step 2: Generate Custom Secure Boot Keys

In NixOS, run `sbctl` to generate your private platform keys (stored securely in `/var/lib/sbctl`):

```bash
# Verify the system is in Setup Mode
sudo sbctl status

# Create custom platform keys
sudo sbctl create-keys
```

______________________________________________________________________

### Step 3: Enroll Keys into UEFI Firmware

Enroll your custom keys along with Microsoft OEM certificates (necessary to prevent bricking option ROMs on GPUs and expansion cards):

```bash
sudo sbctl enroll-keys --microsoft
```

______________________________________________________________________

### Step 4: Sign Bootloader and Kernels

Sign the Limine EFI bootloader and kernel binaries:

```bash
# Sign all EFI binaries in /boot
sudo find /boot -type f -name "*.efi" -exec sbctl sign -s {} +

# Sign all kernel binaries
sudo find /boot -type f \( -name "vmlinuz*" -o -name "bzImage*" \) -exec sbctl sign -s {} +
```

______________________________________________________________________

### Step 5: Enable Automated Secure Boot Signing in Host Config

In `modules/hosts/<hostname>/default.nix`, enable automated signing on future rebuilds:

```nix
myFeatures.core.boot.secureBoot.enable = true;
```

Now, whenever `nixos-rebuild` builds a new generation or kernel, Limine and the kernel will be signed automatically!

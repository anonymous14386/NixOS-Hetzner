#NixOS-Hetzner

Configuration and installation instructions for a Hetzner Dedicated Server using NixOS Flakes and Disko (RAID 0).

#1. Preparation

    Log into the Hetzner Robot panel: https://robot.hetzner.com

    Go to Rescue > Linux > Activate rescue system.

        Tip: Add your SSH key in the rescue dialog to avoid typing passwords.

    Go to Reset > Hardware Reset (Automatic).

    Wait 2-3 minutes, then clear your known hosts (if you've connected to this IP before) and SSH in:
    Bash

    ```ssh-keygen -f "~/.ssh/known_hosts" -R "YOUR_SERVER_IP"
    ssh root@YOUR_SERVER_IP```

When you get back in, the ssh prompt should say root@rescue ~ #.

#2. Install Nix (The Package Manager)

This installs Nix into the RAM disk so we can use it to bootstrap the real install.

```curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh```

#3. Clean Previous Partitions (Critical)

Leftover RAID metadata often causes race conditions (resulting in md127 errors). Run this to stop existing arrays and wipe the disks clean before letting Disko take over.

```# Stop any auto-assembled arrays
mdadm --stop --scan

# Wipe filesystem signatures (Adjust sda/sdb if your disks differ)
wipefs -a /dev/sda /dev/sdb```

#4. Partition the Disks

We use nix run to pull disko directly from GitHub and apply your disk-config.nix.

```nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko --flake github:anonymous14386/NixOS-Hetzner#hetzner-server```

5. Install NixOS

We use nix shell to temporarily access the nixos-install command. We add --no-write-lock-file because we are installing directly from a remote GitHub URL (which is read-only).

```nix --experimental-features 'nix-command flakes' shell nixpkgs#nixos-install-tools -c nixos-install --root /mnt --no-root-passwd --flake github:anonymous14386/NixOS-Hetzner#hetzner-server --no-write-lock-file```

6. Finish

Reboot into your new NixOS installation.
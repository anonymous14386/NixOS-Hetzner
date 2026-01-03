NixOS-Hetzner

Configuration and installation instructions for a Hetzner Dedicated Server using NixOS Flakes and Disko (RAID 0).
1. Preparation

Log into the Hetzner Robot panel and activate Rescue Mode.

    Navigate to: https://robot.hetzner.com

    Go to Rescue > Linux > Activate rescue system.

        Tip: Add your SSH key in the rescue dialog to avoid typing passwords.

    Go to Reset > Hardware Reset (Automatic).

    Wait 2-3 minutes, then clear your known hosts and SSH in:

Bash

ssh-keygen -f "~/.ssh/known_hosts" -R "YOUR_SERVER_IP"
ssh root@YOUR_SERVER_IP

    Note: When you get back in, the ssh prompt should say root@rescue ~ #.

2. Install Nix (The Package Manager)

Install Nix into the RAM disk to bootstrap the real install.
Bash

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

3. Clean Previous Partitions (Critical)

Stop existing arrays and wipe disks to avoid race conditions (md127 errors).
Bash

# Stop any auto-assembled arrays
mdadm --stop --scan

# Wipe filesystem signatures (Adjust sda/sdb if your disks differ)
wipefs -a /dev/sda /dev/sdb

4. Partition the Disks

Use disko to pull your configuration and format the drives.
Bash

nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko --flake github:anonymous14386/NixOS-Hetzner#hetzner-server

5. Install NixOS

Use nix shell to run the install tools against your remote configuration. Note: --no-write-lock-file is required because the remote flake is read-only.
Bash

nix --experimental-features 'nix-command flakes' shell nixpkgs#nixos-install-tools -c nixos-install --root /mnt --no-root-passwd --flake github:anonymous14386/NixOS-Hetzner#hetzner-server --no-write-lock-file

6. Finish

Reboot into your new NixOS installation.
Bash

reboot

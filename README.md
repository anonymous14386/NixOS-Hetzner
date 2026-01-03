# NixOS-Hetzner
Configuration and installation instructions for a Hetzner Dedicated Server using NixOS Flakes and Disko (RAID 0).

## 1. Preparation
1. Log into the Hetzner Robot panel: https://robot.hetzner.com
2. Go to **Rescue** > **Linux** > **Activate rescue system**.
   - *Tip:* Add your SSH key in the rescue dialog to avoid typing passwords.
3. Go to **Reset** > **Hardware Reset** (Automatic).
4. Wait 2-3 minutes, then clear your known hosts (if you've connected to this IP before) and SSH in:
   ```bash
   ssh-keygen -f "~/.ssh/known_hosts" -R "YOUR_SERVER_IP"
   ssh root@YOUR_SERVER_IP

When you get back in the ssh prompt should say "root@rescue ~ #"



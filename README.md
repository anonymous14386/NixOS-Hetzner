# NixOS-Hetzner
installing nixos and configuration instructions for Hetzner dedicated server

# Prep work
We will need a blank server for this, I am using a Hetzner Dedicated Server which can be managed through this panel: https://robot.hetzner.com

Click the rescue tab and select Linux then reset and execute a hardware reset. If your ssh key is not set up you will need the password generated to log in

If this doesn't come back up then order a manual power reset and wait, you should receive an email from Hetzner that it was successfull

When the server comes back up you may need to run "ssh-keygen -f '~/.ssh/known_hosts' -R 'ip address'"
Change the directory if needed and replace 'ip address' with your ip in quotes

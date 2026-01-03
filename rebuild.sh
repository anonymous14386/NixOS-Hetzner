echo "Pull latest configuration from GitHub: "

git pull

echo "Rebuild the system from a flake: 'sudo nixos-rebuild switch --flake .#hetzner-server --impure'"

sudo nixos-rebuild switch --flake .#hetzner-server --impure

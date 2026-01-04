{ config, pkgs, lib, ... }:

let
  wgSubnet = "10.13.13.0/24";  # change if you prefer a different WG subnet
  sshPort = 49213;
  wgPort = 51820;
in
{
  options = { };

  config = {
    # Docker
    virtualisation.docker = {
      enable = true;
      containers = {
        # Portainer (management UI)
        portainer = {
          image = "portainer/portainer-ce:latest";
          ports = [ "9000:9000" "9443:9443" ];
          volumes = [
            "/var/lib/portainer/data:/data"
            "/var/run/docker.sock:/var/run/docker.sock"
          ];
          restartPolicy = "always";
        };

        # Nginx Proxy Manager
        nginx-proxy-manager = {
          image = "jc21/nginx-proxy-manager:latest";
          ports = [ "80:80" "81:81" "443:443" ];
          volumes = [
            "/var/lib/nginx-proxy-manager/data:/data"
            "/var/lib/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
          ];
          restartPolicy = "always";
        };

        # Placeholder apps (replace image with your built image)
        money-tracker = {
          image = "your-registry/money-tracker:latest";
          ports = [ "8081:8080" ]; # host:container
          volumes = [ "/var/lib/money-tracker:/data" ];
          restartPolicy = "always";
        };

        workout-tracker = {
          image = "your-registry/workout-tracker:latest";
          ports = [ "8082:8080" ];
          volumes = [ "/var/lib/workout-tracker:/data" ];
          restartPolicy = "always";
        };
      };
    };

    # Firewall basics
    networking.firewall = {
      enable = true;
      # Keep SSH allowed publicly
      allowedTCPPorts = [ sshPort ];
      # WireGuard listen port (UDP)
      allowedUDPPorts = [ wgPort ];
      # We enforce "internal-only" for management ports using nft rules below:
      extraCommands = lib.mkForce ''
        # Allow WG subnet and loopback to access management ports (Portainer, NPM, apps)
        # Replace inet -> ip if you only want IPv4, but inet covers both families.
        nft add rule inet filter input tcp dport {9000,9443,80,81,443,8081,8082} ip saddr ${wgSubnet} accept
        nft add rule inet filter input tcp dport {9000,9443,80,81,443,8081,8082} iifname "lo" accept
        nft add rule inet filter input tcp dport {9000,9443,80,81,443,8081,8082} counter drop
      '';
    };

    # Optional: enable sshguard if you already have it enabled elsewhere - keep as is
    # Do not set sshd port here to avoid evaluation-order issues; set services.openssh.port in your primary configuration.nix instead.
    services.openssh = {
      enable = true;
      permitRootLogin = "prohibit-password"; # key-only root
      # port intentionally NOT set here to avoid evaluation errors; set in your top-level configuration if desired
    };

    # WireGuard configuration is split to its own module/file (see next file block)
  };
}

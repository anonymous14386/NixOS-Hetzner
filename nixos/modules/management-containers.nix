{ config, pkgs, lib, ... }:

let
  sshPort = 49213;
  docker = pkgs.docker;
in
{
  options = { };

  config = {
    # Enable Docker daemon
    virtualisation.docker.enable = true;

    # Services that run containers using the docker CLI (works reliably across nixpkgs)
    systemd.services.portainer = {
      description = "Portainer (container manager)";
      wants = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStartPre = [
          "${docker}/bin/docker pull portainer/portainer-ce:latest"
          "${docker}/bin/docker rm -f portainer || true"
        ];
        ExecStart = "${docker}/bin/docker run --name portainer --rm -p 9000:9000 -p 9443:9443 -v /var/lib/portainer/data:/data -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce:latest";
        ExecStop = "${docker}/bin/docker stop portainer || true";
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.nginx-proxy-manager = {
      description = "Nginx Proxy Manager";
      wants = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStartPre = [
          "${docker}/bin/docker pull jc21/nginx-proxy-manager:latest"
          "${docker}/bin/docker rm -f nginx-proxy-manager || true"
        ];
        ExecStart = "${docker}/bin/docker run --name nginx-proxy-manager --rm -p 80:80 -p 81:81 -p 443:443 -v /var/lib/nginx-proxy-manager/data:/data -v /var/lib/nginx-proxy-manager/letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest";
        ExecStop = "${docker}/bin/docker stop nginx-proxy-manager || true";
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.money-tracker = {
      description = "Money tracker app";
      wants = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStartPre = [
          "${docker}/bin/docker build -t budget-tracker:latest /home/psychopathy/Documents/NixOS-Hetzner/nixos/modules/budget-tracker"
          "${docker}/bin/docker rm -f money-tracker || true"
        ];
        ExecStart = "${docker}/bin/docker run --name money-tracker --rm --network host -v /var/lib/money-tracker:/usr/src/app budget-tracker:latest";
        ExecStop = "${docker}/bin/docker stop money-tracker || true";
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.workout-tracker = {
      description = "Workout tracker app (placeholder)";
      wants = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStartPre = [
          "${docker}/bin/docker pull your-registry/workout-tracker:latest || true"
          "${docker}/bin/docker rm -f workout-tracker || true"
        ];
        ExecStart = "${docker}/bin/docker run --name workout-tracker --rm -p 8082:8080 -v /var/lib/workout-tracker:/data your-registry/workout-tracker:latest";
        ExecStop = "${docker}/bin/docker stop workout-tracker || true";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Firewall basics
    networking.firewall = {
      enable = true;
      # Keep SSH allowed publicly (note: set the port itself in your top-level configuration.nix)
      allowedTCPPorts = [ sshPort ];
    };

    # Keep ssh enabled here but do NOT set `port` in this module (avoid evaluation-order errors)
  };
}

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

    systemd.services.workout-tracker = {
      description = "Workout tracker app (placeholder)";
      wants = [ "docker.service" ];
      after = [ "docker.service" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStop = "${docker}/bin/docker stop workout-tracker || true";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Firewall basics
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ sshPort ];
    };
  };
}
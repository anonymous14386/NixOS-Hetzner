{ config, pkgs, ... }:

{
  # Crowdsec - Intrusion Detection & Prevention System
  services.crowdsec = {
    enable = true;
    
    # Configure log sources (acquisitions)
    localConfig.acquisitions = [
      {
        filenames = [ "/var/log/auth.log" ];
        labels.type = "syslog";
      }
      {
        filenames = [ "/var/log/nginx/*.log" ];
        labels.type = "nginx";
      }
    ];
  };

  # Note: Firewall bouncer disabled - using fail2ban for blocking
  # Crowdsec will only detect and send email alerts
  
  # Configure API client manually
  environment.etc."crowdsec/config.yaml.local".text = ''
    api:
      client:
        credentials_path: /var/lib/crowdsec/data/local_api_credentials.yaml
  '';
  
  # Point to custom notification and profile locations
  systemd.services.crowdsec.environment = {
    NOTIFICATIONS_DIR = "/var/lib/crowdsec/notifications";
    PROFILES_PATH = "/var/lib/crowdsec/profiles.yaml";
  };

  # Install common scenarios
  systemd.services.crowdsec-install-scenarios = {
    description = "Install Crowdsec scenarios";
    after = [ "crowdsec.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.crowdsec}/bin/cscli collections install crowdsecurity/linux || true
      ${pkgs.crowdsec}/bin/cscli collections install crowdsecurity/sshd || true
      ${pkgs.crowdsec}/bin/cscli collections install crowdsecurity/nginx || true
      ${pkgs.crowdsec}/bin/cscli collections install crowdsecurity/base-http-scenarios || true
      ${pkgs.crowdsec}/bin/cscli collections install crowdsecurity/http-cve || true
      ${pkgs.crowdsec}/bin/cscli collections install crowdsecurity/iptables || true
    '';
  };
}

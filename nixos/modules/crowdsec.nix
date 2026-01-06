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
  
  # Configure API client to look in /var/lib/crowdsec for notifications
  environment.etc."crowdsec/config.yaml.local".text = ''
    api:
      client:
        credentials_path: /var/lib/crowdsec/data/local_api_credentials.yaml
    
    # Use writable locations for notifications and profiles
    config_paths:
      notification_dir: /var/lib/crowdsec/notifications
      profile_dir: /var/lib/crowdsec
  '';

  # Email notification configuration
  environment.etc."crowdsec/notifications/email.yaml".text = ''
    type: email
    name: email_default
    
    # Email settings
    log_level: info
    
    format: |
      {{range . -}}
      {{$alert := . -}}
      {{range .Decisions -}}
      <b>Crowdsec Alert</b>
      
      <b>Type:</b> {{$alert.Scenario}}
      <b>Action:</b> {{.Type}} 
      <b>IP:</b> {{.Value}}
      <b>Reason:</b> {{$alert.Message}}
      <b>Duration:</b> {{.Duration}}
      <b>Time:</b> {{$alert.CreatedAt}}
      
      <b>Events:</b>
      {{range $alert.Events -}}
      - {{.Timestamp}}: {{.Meta.service}} from {{.Meta.source_ip}}
      {{end}}
      
      ---
      {{end}}
      {{end}}
    
    # SMTP settings for octopustechnology.net
    smtp_host: mail.octopustechnology.net
    smtp_port: 587
    smtp_username: ndiramio@octopustechnology.net
    smtp_password: __MAILBOX_PASSWORD__  # Replace with actual password
    
    # Email details
    sender_email: ndiramio@octopustechnology.net
    receiver_emails:
      - ndiramio@octopustechnology.net
    
    # Subject format
    email_subject_prefix: "[Security Alert]"
  '';

  # Crowdsec profiles to enable notifications
  environment.etc."crowdsec/profiles.yaml".text = ''
    name: default_ip_remediation
    filters:
     - Alert.Remediation == true && Alert.GetScope() == "Ip"
    decisions:
     - type: ban
       duration: 4h
    on_success: break
    notifications:
      - email_default
    ---
    name: slow_ban
    filters:
     - Alert.Remediation == true && Alert.GetScope() == "Ip" && Alert.GetScenario() contains "ssh"
    decisions:
     - type: ban
       duration: 24h
    on_success: break
    notifications:
      - email_default
  '';

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

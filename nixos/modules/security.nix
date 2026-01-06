{ config, pkgs, ... }:

{
  # Fail2ban - Automated ban of malicious IPs
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "::1"
      # Add your Tailscale network range here if needed
      # "100.64.0.0/10"  # Uncomment for Tailscale
    ];

    jails = {
      # SSH protection - override default with custom port
      sshd.settings = {
        enabled = true;
        port = "49213";
        maxretry = 3;
        findtime = 600;
        bantime = 3600;
      };
    };
  };

  # Additional fail2ban jails via raw config
  environment.etc."fail2ban/jail.d/custom.local".text = ''
    [sshd-aggressive]
    enabled = true
    port = 49213
    filter = sshd
    maxretry = 5
    findtime = 3600
    bantime = 86400
    logpath = /var/log/auth.log

    [http-get-dos]
    enabled = true
    port = http,https
    filter = http-get-dos
    maxretry = 300
    findtime = 300
    bantime = 600
    logpath = /var/log/nginx/access.log

    [nginx-bad-request]
    enabled = true
    port = http,https
    filter = nginx-bad-request
    maxretry = 2
    findtime = 600
    bantime = 3600
    logpath = /var/log/nginx/access.log

    [postfix]
    enabled = true
    port = smtp,465,submission
    filter = postfix
    maxretry = 3
    findtime = 600
    bantime = 3600
    logpath = /var/log/mail.log

    [postfix-sasl]
    enabled = true
    port = smtp,465,submission,imap,imaps,pop3,pop3s
    filter = postfix[mode=auth]
    maxretry = 3
    findtime = 600
    bantime = 3600
    logpath = /var/log/mail.log

    [dovecot]
    enabled = true
    port = pop3,pop3s,imap,imaps,submission,465,sieve
    filter = dovecot
    maxretry = 3
    findtime = 600
    bantime = 3600
    logpath = /var/log/mail.log
  '';

  # Custom fail2ban filters
  environment.etc = {
    "fail2ban/filter.d/http-get-dos.conf".text = ''
      [Definition]
      failregex = ^<HOST> -.*"(GET|POST).*
      ignoreregex =
    '';

    "fail2ban/filter.d/nginx-bad-request.conf".text = ''
      [Definition]
      failregex = ^<HOST> -.*" (400|444|403|405) 
      ignoreregex =
    '';
  };

  # Additional kernel hardening for DDoS protection
  boot.kernel.sysctl = {
    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_syn_retries" = 2;
    "net.ipv4.tcp_synack_retries" = 2;
    "net.ipv4.tcp_max_syn_backlog" = 4096;

    # Rate limiting
    "net.ipv4.icmp_ratelimit" = 100;
    "net.ipv4.icmp_msgs_per_sec" = 50;

    # Connection tracking
    "net.netfilter.nf_conntrack_max" = 262144;
    
    # Ignore ICMP redirects
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    
    # Ignore source packet routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
  };

  # Firewall rate limiting
  networking.firewall.extraCommands = ''
    # Rate limit SSH connections
    iptables -A INPUT -p tcp --dport 49213 -m state --state NEW -m recent --set
    iptables -A INPUT -p tcp --dport 49213 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
    
    # Rate limit HTTP/HTTPS connections (basic DDoS protection)
    iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set
    iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 1 --hitcount 50 -j DROP
    
    iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m recent --set
    iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m recent --update --seconds 1 --hitcount 50 -j DROP
    
    # Protect against ping floods
    iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 2 -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
  '';
}

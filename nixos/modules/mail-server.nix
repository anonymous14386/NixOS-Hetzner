{ config, pkgs, ... }:

{
  # Email server firewall rules
  networking.firewall = {
    allowedTCPPorts = [
      # SMTP
      25    # SMTP (incoming mail)
      587   # SMTP Submission (authenticated sending)
      465   # SMTPS (legacy, but still used)
      
      # IMAP
      993   # IMAPS (secure IMAP)
      143   # IMAP (optional, prefer 993)
      
      # POP3
      995   # POP3S (secure POP3)
      110   # POP3 (optional, prefer 995)
      
      # Sieve
      4190  # ManageSieve (mail filtering)
    ];
  };
}

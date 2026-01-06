#!/usr/bin/env bash
# Setup Crowdsec email notifications
# This script configures email alerts for Crowdsec

set -e

echo "=== Crowdsec Email Notification Setup ==="
echo

# Prompt for password
read -sp "Enter password for ndiramio@octopustechnology.net: " PASSWORD
echo
echo

# Create the notifications directory if it doesn't exist
sudo mkdir -p /var/lib/crowdsec/notifications

# Create the email configuration
sudo tee /var/lib/crowdsec/notifications/email.yaml > /dev/null <<EOF
type: email
name: email_default

# Email settings
log_level: info

format: |
  {{range . -}}
  {{\$alert := . -}}
  {{range .Decisions -}}
  <b>Crowdsec Alert</b>
  
  <b>Type:</b> {{\$alert.Scenario}}
  <b>Action:</b> {{.Type}} 
  <b>IP:</b> {{.Value}}
  <b>Reason:</b> {{\$alert.Message}}
  <b>Duration:</b> {{.Duration}}
  <b>Time:</b> {{\$alert.CreatedAt}}
  
  <b>Events:</b>
  {{range \$alert.Events -}}
  - {{.Timestamp}}: {{.Meta.service}} from {{.Meta.source_ip}}
  {{end}}
  
  ---
  {{end}}
  {{end}}

# SMTP settings for octopustechnology.net
smtp_host: mail.octopustechnology.net
smtp_port: 587
smtp_username: ndiramio@octopustechnology.net
smtp_password: $PASSWORD

# Email details
sender_email: ndiramio@octopustechnology.net
receiver_emails:
  - ndiramio@octopustechnology.net

# Subject format
email_subject_prefix: "[Security Alert]"
EOF

# Set permissions
sudo chmod 600 /var/lib/crowdsec/notifications/email.yaml

echo "✓ Email configuration created at /var/lib/crowdsec/notifications/email.yaml"

# Create the profiles configuration
sudo tee /var/lib/crowdsec/profiles.yaml > /dev/null <<'EOF'
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
EOF

echo "✓ Profiles configuration created at /var/lib/crowdsec/profiles.yaml"

# Restart crowdsec
echo
echo "Restarting crowdsec..."
sudo systemctl restart crowdsec
sleep 2

echo "✓ Crowdsec restarted"
echo

# Test notification
echo "Testing email notification..."
sudo cscli notifications test email_default

echo
echo "=== Setup Complete ==="
echo "Check your email at ndiramio@octopustechnology.net for the test alert."
echo
echo "To view alerts: sudo cscli alerts list"
echo "To view decisions: sudo cscli decisions list"
echo "To check metrics: sudo cscli metrics"

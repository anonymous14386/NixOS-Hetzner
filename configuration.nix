{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    /root/nixos-config/private.nix
  ];

  # Bootloader
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };

  # SSH & Networking
  services.openssh = {
    enable = true;
    port = 49213;
    settings = {
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      PermitRootLogin = "prohibit-password";
      PermitEmptyPasswords = false;
      X11Forwarding = false;
      UseDNS = false;
      MaxAuthTries = 3;
      LoginGraceTime = "30s";
    };
  };
  
  networking.hostName = "octopus-server";

  # Firewall

  networking.firewall.allowedTCPPorts = [ 49213 80 443 81 5223 5224];

  # User Configuration
  # Root gets keys from GitHub
  users.users.root.openssh.authorizedKeys.keyFiles = [
    (builtins.fetchurl "https://github.com/anonymous14386.keys")
  ];

  # Psychopathy user definition + keys from GitHub
  users.users.psychopathy = {
    isNormalUser = true;
    description = "Psychopathy";
    extraGroups = [ "networkmanager" "wheel" ]; 
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [
      (builtins.fetchurl "https://github.com/anonymous14386.keys")
    ];
  };

  # Docker Configuration
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true; # Automatically clean up unused containers weekly
  };

  # System Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System Packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    docker-compose
    neofetch
  ];

  # Enable sshguard to block repeated SSH offenders
  services.sshguard.enable = true;

  system.stateVersion = "24.11";
}

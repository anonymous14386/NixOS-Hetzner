{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    /root/nixos-config/private.nix
    ./nixos/modules/mail-server.nix
    ./nixos/modules/security.nix
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
    settings.PermitRootLogin = "prohibit-password";  # keep key-only root
  };
  
  networking.hostName = "octopus-server";

  # Tailscale
  services.tailscale.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;


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
    curl
    docker-compose
    neofetch
    tailscale
    openssl
    jq
    gnugrep
    gnused
    gawk
    coreutils
  ];

  system.stateVersion = "24.11";
}

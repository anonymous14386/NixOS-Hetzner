{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # PASTE YOUR PUBLIC SSH KEY BELOW
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbr/7wNV/23NREyNjjzcC4XS1bHRktQD2DEGjFMn5GMarKbazUk+Lm0LUHdeKRLLcEIWZX3b+IvKkyVABz04queQ1ELD7fipWrYRdCjhW5WS2rNIKRrWUaGX05sXMC0V1l9VBHgNScuImT9PR5XECpdtcvIzLKwfFJIvd5EESH/E9gxefip1cAUmiFfKAb8e/YpW1I/WYoua160UpGXvWhK2dkGWcAQ1wY7T3dR7C6DQVtNR3Mowunl9mGoaXNqdNHiR+h7siSKldY+c8EF34run7pzPvqZpIRMHfjY/D6K5OSnGZc+lVV9/PmDO7TXm1dZPJjl1d8CWMNdciVlT0X9S+PhB/VEOorjkzg2pVzrYrLKLP/tsR/VH0MW28ZFUbBWM87nIXGzgML3LUOICnzFw1D2ALCFxSkxQ0UkhKzs8j5h5sfPb1fbdfXeQsVe8Kg5ryj3lVwM/6AC5JYP1qgYGsjOLThBlE8ID6Jm2FdgC4I7fn1WyOMIBQ5zn0NQT0/dEWqkm8GlUV4n5cOKlcK97+dA8h3OOdp0nw1FjDv0g0l4+ZXixs9JLGJuITHBKDDe+jyXDcMGlRVm8vegtMkRBhCu4y8xOy0c5JIYJmknG5Ko3q91gesdtSRzj8q8NrFNvWdXRnKQXm1fteMR7bpBlJue1KHcrkOb033wMZMww== JuiceSSH" 
  ];

  # Enable nix-command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  users.users.psychopathy = {
    isNormalUser = true;
    description = "Psychopathy";
    extraGroups = [ "networkmanager" "wheel" ]; # 'wheel' enables sudo
    packages = with pkgs; [];
  };

  networking.hostName = "octopus-server";
  system.stateVersion = "23.11"; 
}

{ config, pkgs, lib, ... }:

let
  wgIface = "wg0";
  wgAddress = "10.13.13.1/24"; # server WG address
  wgListenPort = 51820;
in
{
  options = { };

  config = {
    networking.wireguard.interfaces = {
      "${wgIface}" = {
        ips = [ wgAddress ];
        listenPort = wgListenPort;
        # This example expects you to generate /etc/wireguard/server_privatekey
        privateKeyFile = "/etc/wireguard/server_privatekey";
        generatePrivateKeyFile = true; # Automatically generate the private key if it doesn't exist
        # To get the public key for client configuration, run the following command on the server:
        # wg show ${wgIface} public-key
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wgIface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enp0s31f6 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wgIface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp0s31f6 -j MASQUERADE
        '';
        peers = [
          # example peer stub; replace PUBLIC_KEY with actual client pubkey and the IP
          {
            publicKey = "u8Q6TonsXOlzzu/5lRLfOFi+HeMw8RqbhwS7KBplQiw=";
            allowedIPs = [ "10.13.13.2/32" ];
          }
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /etc/wireguard 0750 root root -"
    ];
  };
}

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
        peers = {
          # example peer stub; replace PUBLIC_KEY with actual client pubkey and the IP
          client-1 = {
            publicKey = "CLIENT1_PUBLIC_KEY";
            allowedIPs = [ "10.13.13.2/32" ];
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /etc/wireguard 0750 root root -"
    ];
  };
}

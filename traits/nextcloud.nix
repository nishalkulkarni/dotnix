{ config, pkgs, ... }:

{
  config = {
    services.nginx.virtualHosts."nc.nishalkulkarni.com" = {
      extraConfig = ''
        client_max_body_size 50000M;
      '';
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:30451";
        proxyWebsockets = true;
      };
    };
    
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        nextcloud-aio-mastercontainer = {
          image = "nextcloud/all-in-one:latest";
          autoStart = false;
          ports = [ "30451:30451" ];
          volumes = [
            "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
            "/var/run/docker.sock:/var/run/docker.sock:ro"
          ];
          environment = { NEXTCLOUD_DATADIR = "/mnt/storage/nextcloud_data"; };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 443 3478 ];
    networking.firewall.allowedUDPPorts = [ 443 3478 ];
  };
}

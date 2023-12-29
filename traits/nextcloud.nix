{ config, pkgs, ... }:

{
  config = {
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        nextcloud-aio-mastercontainer = {
          image = "nextcloud/all-in-one:latest";
          autoStart = true;
          ports = [ "30451:8080" ];
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

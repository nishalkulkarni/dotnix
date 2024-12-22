{ config, pkgs, ... }:

let
  immichHost = "immich.hs.nishalkulkarni.com";
  immichVersion = "release";
  timezone = "Europe/Berlin";
  uploadLocation = "/mnt/storage/immich/library";
  mlDataLocation = "/var/lib/immich/mldata";

  dbLocation = "/var/lib/immich/db/postgres";
  dbHostname = "immich_postgres";
  dbName = "immich";
  dbUsername = "postgres";
  dbPassword = builtins.readFile config.sops.secrets.immich_postgres_pass.path;

  redistHostname = "immich_redis";
in {
  config = {
    services.nginx.virtualHosts."${immichHost}" = {
      extraConfig = ''
        ## Per https://immich.app/docs/administration/reverse-proxy
        client_max_body_size 50000M;
      '';
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true;
      };
    };

    systemd.services.init-filerun-network-and-files = {
      description = "Create the network bridge for Immich.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = let dockercli = "${config.virtualisation.docker.package}/bin/docker";
              in ''
                # immich-net network
                check=$(${dockercli} network ls | grep "immich-net" || true)
                if [ -z "$check" ]; then
                  ${dockercli} network create immich-net
                else
                  echo "immich-net already exists in docker"
                fi
              '';
    };

    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        immich_server = {
          autoStart = true;
          image = "ghcr.io/immich-app/immich-server:${immichVersion}";
          ports = [ "2283:2283" ];
          volumes = [
            "${uploadLocation}:/usr/src/app/upload"
            "/etc/localtime:/etc/localtime:ro"
          ];
          dependsOn = [ "immich_redis" "immich_postgres" ];
          extraOptions = [ "--network=immich-net" ];
          environment = {
            TZ = timezone;
            IMMICH_VERSION = immichVersion;
            UPLOAD_LOCATION = uploadLocation;
            DB_DATA_LOCATION = dbLocation;
            DB_HOSTNAME = dbHostname;
            DB_DATABASE_NAME = dbName;
            DB_USERNAME = dbUsername;
            DB_PASSWORD = dbPassword;
	          REDIS_HOSTNAME = redistHostname;
          };
        };

        immich_machine_learning = {
          autoStart = true;
          image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
          volumes = [
            "${mlDataLocation}/model-cache:/cache"
          ];
          extraOptions = [ "--network=immich-net" ];
          environment = {
            IMMICH_VERSION = immichVersion;
          };
        };

        immich_redis = {
          autoStart = true;
          image = "redis:6.2-alpine";
          extraOptions = [ "--network=immich-net" ];
        };

        immich_postgres = {
          autoStart = true;
          image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
          extraOptions = [ "--network=immich-net" ];
          environment = {
            POSTGRES_PASSWORD = dbPassword;
            POSTGRES_USER = dbUsername;
            POSTGRES_DB = dbName;
            POSTGRES_INITDB_ARGS = "--data-checksums";
          };
          volumes = [
            "${dbLocation}:/var/lib/postgresql/data"
          ];
          cmd = [
            "postgres"
            "-c" "shared_preload_libraries=vectors.so"
            "-c" "search_path=\"$$user\", public, vectors"
            "-c" "logging_collector=on"
            "-c" "max_wal_size=2GB"
            "-c" "shared_buffers=512MB"
            "-c" "wal_compression=on"
          ];
        };

      };
    };

    networking.firewall.allowedTCPPorts = [ 2283 3003 ];
    networking.firewall.allowedUDPPorts = [ 2283 3003 ];
  };
}

{ config, pkgs, ... }:

let
  immichVersion = "release";
  timezone = "Europe/Berlin";
  uploadLocation = "/mnt/storage/immich/library";
  mlDataLocation = "/var/lib/immich/mldata";

  dbLocation = "/var/lib/immich/db/postgres";
  dbName = "immich";
  dbUsername = "postgres";
  dbPassword = "postgres"; # Change to random password, used internally
in {
  config = {
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
          environment = {
            TZ = timezone;
            IMMICH_VERSION = immichVersion;
            UPLOAD_LOCATION = uploadLocation;
            DB_DATA_LOCATION = dbLocation;
            DB_DATABASE_NAME = dbName;
            DB_USERNAME = dbUsername;
            DB_PASSWORD = dbPassword;
	    REDIS_HOSTNAME = "immich_redis";
          };
        };

        immich_machine_learning = {
          autoStart = true;
          image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
          volumes = [
            "${mlDataLocation}/model-cache:/cache"
          ];
          environment = {
            IMMICH_VERSION = immichVersion;
          };
        };

        immich_redis = {
          autoStart = true;
          image = "redis:6.2-alpine";
        };

        immich_postgres = {
          autoStart = true;
          image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
          environment = {
            POSTGRES_PASSWORD = "${dbPassword}";
            POSTGRES_USER = "${dbUsername}";
            POSTGRES_DB = "${dbName}";
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

    networking.firewall.allowedTCPPorts = [ 2283 ];
    networking.firewall.allowedUDPPorts = [ 2283 ];
  };
}

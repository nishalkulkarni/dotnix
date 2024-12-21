{ config, pkgs, ... }:

{
  config = {
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        immich_server = {
          autoStart = true;
          image = "ghcr.io/immich-app/immich-server:${IMMICH_VERSION:-release}";
          ports = [ "2283:2283" ];
          volumes = [
            "${UPLOAD_LOCATION}:/usr/src/app/upload"
            "/etc/localtime:/etc/localtime:ro"
          ];
          dependsOn = [ "immich_redis" "immich_postgres" ];
          environment = {
            TZ = "Europe/Berlin";
            IMMICH_VERSION = "release";
            UPLOAD_LOCATION = "/mnt/storage/immich/library";
            DB_DATA_LOCATION = "$HOME/DB/postgres";
            DB_PASSWORD = "postgres"; # Change to random password, used internally
            DB_USERNAME = "postgres";
            DB_DATABASE_NAME = "immich";
          };
        };

        immich_machine_learning = {
          autoStart = true;
          image = "ghcr.io/immich-app/immich-machine-learning:${IMMICH_VERSION:-release}";
          volumes = [
            "model-cache:/cache"
          ];
          environment = {
            IMMICH_VERSION = "release";
          };
        };

        immich_redis = {
          autoStart = true;
          image = "redis:6.2-alpine";
          ports = [ "6379:6379" ];
        };

        immich_postgres = {
          autoStart = true;
          image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
          environment = {
            POSTGRES_PASSWORD = "${DB_PASSWORD}";
            POSTGRES_USER = "${DB_USERNAME}";
            POSTGRES_DB = "${DB_DATABASE_NAME}";
            POSTGRES_INITDB_ARGS = "--data-checksums";
          };
          volumes = [
            "${DB_DATA_LOCATION}:/var/lib/postgresql/data"
          ];
          cmd = [
            "postgres"
            "-c shared_preload_libraries=vectors.so"
            "-c 'search_path=\"$$user\", public, vectors'"
            "-c logging_collector=on"
            "-c max_wal_size=2GB"
            "-c shared_buffers=512MB"
            "-c wal_compression=on"
          ];
        };

      };
    };
  };
}

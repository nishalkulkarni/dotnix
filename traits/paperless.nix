{ config, pkgs, ... }:

let
  paperlessHost = "paperless.nishalkulkarni.com";

  serviceName = "paperless-ngx";
  redisBroker = "${serviceName}-broker";
  redisLocation = "/var/lib/${serviceName}/redisdata";
  
  db = "${serviceName}-db";
  dbLocation = "/var/lib/${serviceName}/db/postgres";
  dbName = "paperless";
  dbUsername = "postgres";
  dbPassword = builtins.readFile config.sops.secrets.paperless_postgres_pass.path;
  tokensSecretKey = builtins.readFile config.sops.secrets.paperless_secret_key.path;

  webServer = "${serviceName}-webserver";
  gotenberg = "${serviceName}-gotenberg";
  tika = "${serviceName}-tika";

  extDataLocation = "/mnt/storage/paperless/data";
  extMediaLocation = "/mnt/storage/paperless/media";
  extExportLocation = "/mnt/storage/paperless/export";
  extConsumeLocation = "/mnt/storage/paperless/consume";

  timezone = "Europe/Berlin";
in {
  config = {
    services.nginx.virtualHosts."${paperlessHost}" = {
      ## Per https://github.com/paperless-ngx/paperless-ngx/wiki/Using-a-Reverse-Proxy-with-Paperless-ngx#nginx
      extraConfig = ''
        client_max_body_size 4096M;
      '';
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:28981";
        proxyWebsockets = true;
      };
    };

    systemd.services."init-${webServer}-network" = {
      description = "Create the network bridge for paperless-ngx.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script =
        let dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in ''
          # ${webServer} network
          check=$(${dockercli} network ls | grep "${webServer}" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create ${webServer}
          else
            echo "${webServer} network already exists in docker"
          fi
        '';
    };

    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        "${redisBroker}" = {
          autoStart = true;
          image = "docker.io/library/redis:8";
          volumes = [ "${redisLocation}:/data" ];
          extraOptions = [ "--network=${webServer}" ];
        };

        "${db}" = {
          autoStart = true;
          image = "docker.io/library/postgres:17";
          volumes = [ "${dbLocation}:/var/lib/postgresql/data" ];
          extraOptions = [ "--network=${webServer}" ];
          environment = {
            POSTGRES_PASSWORD = dbPassword;
            POSTGRES_USER = dbUsername;
            POSTGRES_DB = dbName;
          };
        };

        "${webServer}" = {
          autoStart = true;
          image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
          extraOptions = [ "--network=${webServer}" "--pull=always" ];
          dependsOn = [ "${db}" "${redisBroker}" "${gotenberg}"  "${tika}"];
          ports = [ "28981:28981" ];
          volumes = [
            "${extDataLocation}:/usr/src/paperless/data"
            "${extMediaLocation}:/usr/src/paperless/media"
            "${extExportLocation}:/usr/src/paperless/export"
            "${extConsumeLocation}:/usr/src/paperless/consume"
          ];
          environment = {
            PAPERLESS_REDIS = "redis://${redisBroker}:6379";
            PAPERLESS_DBHOST = "${db}";
            PAPERLESS_DBNAME = "${dbName}";
            PAPERLESS_DBUSER = "${dbUsername}";
            PAPERLESS_DBPASS = "${dbPassword}";
            PAPERLESS_TIKA_ENABLED = "1";
            PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://${gotenberg}:3000";
            PAPERLESS_TIKA_ENDPOINT = "http://${tika}:9998";

            PAPERLESS_URL = "https://${paperlessHost}";
            PAPERLESS_PORT = "28981";
            PAPERLESS_TIME_ZONE = "${timezone}";
            PAPERLESS_OCR_LANGUAGE = "eng";
            PAPERLESS_OCR_LANGUAGES = "deu hin mar";

            USERMAP_UID = "33";
            USERMAP_GID = "0";
            PAPERLESS_SECRET_KEY = "${tokensSecretKey}";
          };
        };

        "${gotenberg}" = {
          autoStart = true;
          image = "docker.io/gotenberg/gotenberg:8.20";
          extraOptions = [ "--network=${webServer}" ];
          entrypoint = "gotenberg";
          cmd = [ "--chromium-disable-routes=true" "--chromium-allow-list=file:///tmp/.*" ];
        };

        "${tika}" = {
          autoStart = true;
          image = "ghcr.io/paperless-ngx/tika:latest";
          extraOptions = [ "--network=${webServer}" "--pull=always" ];
        };
      };
    };
  };
}


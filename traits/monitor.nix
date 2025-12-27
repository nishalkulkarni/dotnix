{ config, pkgs, ... }:

let
  grafanaHost = "grafana.nishalkulkarni.com";
  grafanaPort = 7139;
  prometheusPort = 9001;
in
{
  config = {
    services.nginx.virtualHosts."${grafanaHost}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString grafanaPort}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    services.prometheus = {
      enable = true;
      port = prometheusPort;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
      scrapeConfigs = [
        {
          job_name = "scraper";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
      ];

    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          # Listening Address and Port
          http_addr = "127.0.0.1";
          http_port = grafanaPort;
          # Grafana needs to know on which domain and URL it's running
          domain = grafanaHost;
          serve_from_sub_path = true;
        };
      };
    };
  };
}

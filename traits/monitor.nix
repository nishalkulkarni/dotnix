{ config, pkgs, ... }:

let
  grafanaHost = "grafana.nishalkulkarni.com";
  grafanaPort = 7139;
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

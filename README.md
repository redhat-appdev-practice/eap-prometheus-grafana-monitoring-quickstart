# Overview

This repository is a quick start for running Prometheus and Grafana using https://podman.io/[podman]. The configuration files are set up to monitor JBoss EAP/Wildlfy Enterprise Java Application Servers. Collecting the metrics is intended to be used with various tuning guides in order to improve performance of applications running on the application server(s).

## Prerequisites

* Podman >= 4.0
* One or more JBoss EAP/Wildfly instances configured such that the management interface is accessible
* OPTIONAL: A [`node_exporter`](https://github.com/prometheus/node_exporter) running on the target system to monitor OS metrics

## Getting Started

1. Clone this repository
1. Edit the `prometheus.yml` file and change the `targets` for metrics collection.
   *  ```yaml
      scrape_configs:
      # this is the configuration to poll metrics from WildFly 15
      - job_name: 'metrics'
        metrics_path: /metrics
        scrape_interval: 5s
        static_configs:
          - targets:
              - '192.168.100.10:9990'
              - '192.168.100.15:9990'
              - '192.168.100.20:9990'
      # this is the configuration to poll metrics from the host OS if `node_exporter` is installed
      - job_name: 'host'
        metrics_path: /metrics
        scrape_interval: 5s
        static_configs:
          - targets:
            # Add hosts to collect OS metrics and the appropriate port
            - '192.168.100.10:9100'
            - '192.168.100.15:9100'
            - '192.168.100.20:9100'
            - '192.168.100.60:9100'
            - '192.168.100.70:9100'
      ```
    * Each target should be the IP and port of the management interface for the JBoss EAP/Wildlfy instances which have metrics enabled
    * The `scrape_interval` can be adjusted as desired
    * If your hostnames or IP addresses are not very friendly to read, you can use a `relabel_configs` section to map those to more readable names:
      ```yaml
      scrape_configs:
      # this is the configuration to poll metrics from WildFly 15
      - job_name: 'metrics'
        metrics_path: /metrics
        scrape_interval: 5s
        static_configs:
          - targets:
            # Add hosts to collect JBoss metrics and the appropriate port
            - '192.168.100.10:9990'
            - '192.168.100.15:9990'
            - '192.168.100.20:9990'
        relabel_configs:
        - source_labels: [__address__]    # The address configured in the targets above
          separator: ':'
          regex: '192\.168\.100\.10:(.*)' # The regular expression to match with
          replacement: 'jboss01'          # The replacement (including any capture groups)
          target_label: instance          # The label where the new value will be placed
        - source_labels: [__address__]
          separator: ':'
          regex: '192\.168\.100\.15:(.*)'
          replacement: 'jboss02'
          target_label: instance
        - source_labels: [__address__]
          separator: ':'
          regex: '192\.168\.100\.20:(.*)'
          replacement: 'jboss03'
          target_label: instance
      ```
1. If necessary, the scrape configuration can include basic auth credentials for the targets
   *  ```yaml
      scrape_configs:
      # this is the configuration to poll metrics from WildFly 15
      - job_name: 'metrics'
        metrics_path: /metrics
        scrape_interval: 5s
        static_configs:
          - targets:
              - '192.168.100.10:9990'
              - '192.168.100.15:9990'
              - '192.168.100.20:9990'
        basic_auth:
          username: '<username>'
          password: '<password>'
      ```
1. Once the prometheus configuration has been updated, start the monitoring stack
   * `./monitoring.sh`
1. Navigate to the Grafana console using http://localhost:3000/
1. Log in with the default `admin:admin` credentials
   * It is fine to change the default credentials if desired. Keep in mind that those credentials are stored in the podman volume and will be reset if that volume is deleted.
1. Click on **Dashboards**

You can now start creating visualizations using the Prometheus datasource
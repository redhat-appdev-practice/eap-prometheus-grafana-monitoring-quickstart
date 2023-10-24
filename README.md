# Overview

This repository is a quick start for running Prometheus and Grafana using https://podman.io/[podman]. The configuration files are set up to monitor JBoss EAP/Wildlfy Enterprise Java Application Servers. Collecting the metrics is intended to be used with various tuning guides in order to improve performance of applications running on the application server(s).

## Prerequisites

* Podman >= 4.0
* One or more JBoss EAP/Wildfly instances configured such that the management interface is accessible

## Getting Started

1. Clone this repository
1. Edit the `prometheus.yml` file and change the `targets` for metrics collection.
   * ```yaml
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
     ```
    * Each target should be the IP and port of the management interface for the JBoss EAP/Wildlfy instances which have metrics enabled
    * The `scrape_interval` can be adjusted as desired
1. If necessary, the scrape configuration can include basic auth credentials for the targets
   * ```yaml
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
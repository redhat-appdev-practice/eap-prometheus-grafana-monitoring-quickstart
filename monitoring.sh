#!/bin/bash
## Copyright 2023 Red Hat Inc.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

export ENABLE_ALERT_MANAGER=0

while getopts "a:" arg; do
  case $arg in
    a)
      echo "Enable AlertManager"
      export ENABLE_ALERT_MANAGER=1
      ;;
  esac

if ! podman volume exists prometheus-data
then
  podman volume create prometheus-data
fi

if ! podman volume exists grafana-data
then
  podman volume create grafana-data
fi

if ! podman volume exists jaeger-data
then
  podman volume create jaeger-data
fi

if [ ${ENABLE_ALERT_MANAGER} -eq 1 ]; then
  cat monitoring.yml | envsubst | \
    tee last-pod-run.yml | podman play kube --replace -
else 
  cat monitoring.yml | 
    yq 'del(.spec.containers.[] | select(.name == "alertmanager") )' | \
    yq 'del(.spec.volumes.[] | select(.name == "alertmanager-config") )' | \
    envsubst | tee last-pod-run.yml | \
    podman play kube --replace -
fi
#!/usr/bin/env bash

set -eu

! [ -x "$(command -v yq)" ] && echo 'yq not installed, the hook requires it.' && exit 1

name="rhacs-consolidated-configmap"
yq ".data.json = ($(cat generated/dashboards/rhacs-consolidated.json) | to_json)" templates/dashboards/"$name".yaml > "$name".yaml

name="rhacs-consolidated-grafanadashboard"
yq ".spec.json = ($(cat generated/dashboards/rhacs-consolidated.json) | to_json)" templates/dashboards/"$name".yaml > "$name".yaml
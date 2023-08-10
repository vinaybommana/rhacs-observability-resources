#!/usr/bin/env bash

set -eu

if ! [ -x "$(command -v dashboard-lint)" ]; then
	go install github.com/grafana/dashboard-linter@latest
fi

! [ -x "$(command -v yq)" ] && echo 'yq not installed, the hook requires it.' && exit 1

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd 2>/dev/null)"

for var in "$@"; do
    TMPDIR="$(mktemp -d)"
    cp "${SCRIPT_DIR}"/.lint "${TMPDIR}"/.lint
	# Don't lint dashboards auto-generated by mixins.
	if [[ "$var" == resources/grafana/mixins/kubernetes* ]]; then
		continue
	fi
	# Don't lint templates folder and files other than yaml/json in grafana folder
	if [[ "$var" == resources/grafana/templates* || "$var" != *.json || "$var" != *.yaml ]]; then
		continue
	fi
	yq eval '.spec.json' "$var" >"${TMPDIR}"/dashboard.json
	dashboard-linter lint "${TMPDIR}"/dashboard.json --strict --verbose
    rm -rf "$TMPDIR"
done

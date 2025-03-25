#!/bin/bash

declare -A latest_versions
declare -A latest_lines

while IFS=, read -r PKG VERSION CONFIG URL FILENAME _; do
    if [ -z "${latest_versions[$PKG]}" ] || dpkg --compare-versions "$VERSION" gt "${latest_versions[$PKG]}"; then
        latest_versions["$PKG"]="$VERSION"
        latest_lines["$PKG"]="$PKG,$VERSION,$CONFIG,$URL,$FILENAME"
    fi
done </dev/stdin

printf "%s\n" "${latest_lines[@]}"

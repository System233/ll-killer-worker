#!/bin/bash

declare -A latest_versions
declare -A latest_lines

while IFS= read -r LINE; do
    PKG=$(echo "$LINE" | cut -d, -f1 | xargs)
    VERSION=$(echo "$LINE" | cut -d, -f2 | xargs)

    if [[ -z "${latest_versions[$PKG]}" ]] || dpkg --compare-versions "$VERSION" gt "${latest_versions[$PKG]}"; then
        latest_versions["$PKG"]="$VERSION"
        latest_lines["$PKG"]="$LINE"
    fi
done </dev/stdin

printf "%s\n" "${latest_lines[@]}"

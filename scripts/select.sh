#!/bin/bash
# OUTPUT="$1"
# apt update -y
CONFIG="$1"
shift 1
for PKG in "$@";do
    VERSION=$(apt-cache show "$PKG" --no-all-versions | grep -oP '^Version:\s(\d+:)?\K\S+')
    echo "$PKG,$VERSION,$CONFIG"
done
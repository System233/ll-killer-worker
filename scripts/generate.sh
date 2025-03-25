#!/bin/bash
# OUTPUT="$1"
# apt update -y
CONFIG="$1"
function check() {
    while read -r PKG; do
        VERSION=$(apt-cache show "$PKG" --no-all-versions | grep -oP '^Version:\s(\d+:)?\K\S+')
        echo "$PKG,$VERSION,$CONFIG"
    done
}
export -f check 
apt-file find -x "applications/.*\.desktop$" | cut -d: -f1 | sort -u | xargs -P 4 -I {} bash -c 'echo {} | check'

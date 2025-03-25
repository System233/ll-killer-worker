#!/bin/bash

PKG_INDEX=$1
REPO_BRANCH=artifacts
WORK_DIR="${REPO_BRANCH}"
trap exit SIGPIPE
while IFS=, read -r PKG VERSION SRC; do
    PKG_WORK_DIR="${WORK_DIR}/${PKG}"
    PKG_VERSION_FILE="${PKG_WORK_DIR}/version"
    PKG_VERSION=$(cat "$PKG_VERSION_FILE" 2>/dev/null)
    if [ "$VERSION" != "$PKG_VERSION" ]; then
        echo "$PKG" 2>/dev/null
    fi
done <"${PKG_INDEX}"

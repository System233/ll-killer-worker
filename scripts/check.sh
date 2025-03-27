#!/bin/bash

PKG_INDEX=$1
WORK_DIR="build/${ARCH}"
trap exit SIGPIPE
HASH=$(cat .version)
while IFS=, read -r PKG VERSION SRC; do
    PKG_WORK_DIR="${WORK_DIR}/${PKG}"
    PKG_VERSION_FILE="${PKG_WORK_DIR}/version"
    PKG_VERSION=$(cat "$PKG_VERSION_FILE" 2>/dev/null)
    VERSION_HASH="$VERSION-$HASH"
    if [ "$VERSION" != "$PKG_VERSION" ] && [ "$VERSION_HASH" != "$PKG_VERSION" ]; then
        echo "$PKG" 2>/dev/null
    fi
done <"${PKG_INDEX}"

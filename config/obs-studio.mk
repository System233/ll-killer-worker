ARCH=amd64
SOURCES=config/sources/ubuntu-noble.list
ARGS= CREATE_ARGS="--base org.deepin.base/23.1.0" ENABLE_OSTREE=1

REPO:=obsproject/obs-studio
PKG=obs-studio

include common/github.mk
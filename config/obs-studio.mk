SOURCES=config/sources/ubuntu-noble.list
BASE=org.deepin.base/23.1.0

REPO:=obsproject/obs-studio
PKGID=obs-studio

ifeq ($(ARCH),amd64)
include config/strategy/base.mk
include config/strategy/github.mk
else
index:
endif
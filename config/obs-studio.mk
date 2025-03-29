SOURCES=config/sources/ubuntu-noble-$(ARCH).list
BASE=org.deepin.base/23.1.0

REPO:=obsproject/obs-studio
PKGID=obs-studio

ARCH_FILTER=amd64
PATTERN=.*x86_64\\.deb

include config/strategy/github.mk
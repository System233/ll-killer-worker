SOURCES=config/sources/ubuntu-noble-$(ARCH).list config/sources/shiftkey.list
BASE=org.deepin.base/23.1.0
SELECT=github-desktop
ARCH_FILTER=amd64

include config/strategy/apt-select.mk
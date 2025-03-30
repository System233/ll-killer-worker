SOURCES=config/sources/ubuntu-noble-$(ARCH).list config/sources/kicad.list
BASE=org.deepin.base/23.1.0
SELECT=kicad

include config/strategy/apt-select.mk
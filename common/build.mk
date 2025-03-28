include common/env.mk
include common/ll-killer.mk

# make build PKGID=app URL=http

CONFIG ?=
-include config/$(CONFIG).mk

PKGID ?=
ARGS ?=
VERSION ?=

$(if $(PKGID),,$(error "未提供PKGID参数"))

URL?=
FILENAME?=$(PKGID).deb
PKG = $(if $(URL),./$(FILENAME),$(PKGID))

FTP_URL ?=
SSH_URL ?=
SSH_ARGS?=

GITHUB_SERVER_URL ?=
GITHUB_REPOSITORY ?=

WORK_DIR ?= caches
PKG_WORK_DIR ?= $(WORK_DIR)/$(PKGID)
PKG_RESOURCE_DIR ?=	"$(OVERRIDE_DIR)/$(PKGID)" \
					"$(OVERRIDE_DIR)/$(PKGID)-$(ARCH)" \
					"$(OVERRIDE_DIR)/$(PKGID)-$(CONFIG)" \
					"$(OVERRIDE_DIR)/$(PKGID)-$(ARCH)-$(CONFIG)"
PKG_RESOURCE_DIR := $(foreach dir, $(PKG_RESOURCE_DIR), $(if $(wildcard $(dir)), $(dir),))
PKG_RESOURCE_DIR := $(filter-out ,$(PKG_RESOURCE_DIR))

SOURCES += $(foreach dir, $(PKG_RESOURCE_DIR), $(if $(wildcard $(dir)/sources.list), $(dir)/sources.list,))
SOURCES := $(filter-out ,$(SOURCES))

build: $(KILLER)
	mkdir -p "$(PKG_WORK_DIR)"
	echo -n "$(VERSION)"> "$(PKG_WORK_DIR)/version"
	$(foreach dir, $(PKG_RESOURCE_DIR), cp -arfTL "$(dir)" "$@")
ifneq ($(SOURCES),)
	cat $(SOURCES) >"$(PKG_WORK_DIR)/sources.list"
endif
	cd "$(PKG_WORK_DIR)";$(KILLER) -v|tee "killer-version";$(KILLER) init ;
ifneq ($(URL),)
	wget -nv "$(URL)" -O "$(PKG_WORK_DIR)/$(FILENAME)"
endif
	$(MAKE) -C "$(PKG_WORK_DIR)" config PKG=$(PKG) PKGID=$(PKGID) $(ARGS)
	echo "cat /etc/resolv.conf" | $(MAKE) -C "$(PKG_WORK_DIR)" build
	$(MAKE) -C "$(PKG_WORK_DIR)" layer
	cd $(PKG_WORK_DIR); ls *.layer | xargs -rI{} sh -c 'sha256sum {} >{}.sha256sum';cat *.sha256sum > SHA256SUMS; true
test:
	$(MAKE) -C "$(PKG_WORK_DIR)" test

all: build

.PHONY: all build test
.DEFAULT_GOAL := all 
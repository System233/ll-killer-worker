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

REPO_URL ?= $(GITHUB_SERVER_URL)/$(GITHUB_REPOSITORY).git
REPO_BRANCH ?= artifacts

WORK_DIR = $(REPO_BRANCH)
PKG_WORK_DIR ?= $(WORK_DIR)/$(PKGID)
PKG_RESOURCE_DIR ?=	"$(PKG_DIR)/$(PKGID)" \
					"$(PKG_DIR)/$(PKGID)-$(ARCH)" \
					"$(PKG_DIR)/$(PKGID)-$(CONFIG)" \
					"$(PKG_DIR)/$(PKGID)-$(ARCH)-$(CONFIG)"
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
	cd "$(PKG_WORK_DIR)";$(KILLER) init ;
ifneq ($(URL),)
	wget -nv "$(URL)" -O "$(PKG_WORK_DIR)/$(FILENAME)"
endif
	$(MAKE) -C "$(PKG_WORK_DIR)" config PKG=$(PKG) PKGID=$(PKGID) $(ARGS)
	echo "cat /etc/resolv.conf" | $(MAKE) -C "$(PKG_WORK_DIR)" build
	$(MAKE) -C "$(PKG_WORK_DIR)" layer
	cd $(PKG_WORK_DIR); sha256sum *.layer >SHA256SUMS
	cat $(PKG_WORK_DIR)/SHA256SUMS >> $(WORK_DIR)/SHA256SUMS
test:
	$(MAKE) -C "$(PKG_WORK_DIR)" test
push:
	git -C $(PKG_WORK_DIR) add .
	git -C $(PKG_WORK_DIR) diff --cached --quiet || git -C $(PKG_WORK_DIR) commit -m "Update $(PKGID)"
	git -C $(PKG_WORK_DIR) pull origin artifacts --rebase --strategy=ours
	git -C $(PKG_WORK_DIR) push -u origin HEAD:artifacts

upload:
ifneq ($(FTP_URL),)
	echo "Uploading to ftp"
	curl -T $(PKG_WORK_DIR)/*.layer $(FTP_URL)
endif
ifneq ($(SSH_URL),)
	echo "Uploading to scp"
	scp $(SSH_ARGS) $(PKG_WORK_DIR)/*.layer $(SSH_URL)
endif

all: build push upload

.PHONY: all build push upload test
.DEFAULT_GOAL := all 
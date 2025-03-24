include common/ll-killer.mk

# make build PKG=app URL=http

CONFIG ?=
-include config/$(CONFIG).mk

PKG ?=
ARGS ?=
FTP_URL ?=
SCP_URL ?=

GITHUB_SERVER_URL ?=
GITHUB_REPOSITORY ?=

REPO_URL ?= $(GITHUB_SERVER_URL)/$(GITHUB_REPOSITORY).git
REPO_BRANCH ?= artifacts

WORK_DIR = $(REPO_BRANCH)
PKG_WORK_DIR ?= $(WORK_DIR)/$(PKG)
PKG_RESOURCE_DIR ?=	"$(PKG_DIR)/$(PKG)" \
					"$(PKG_DIR)/$(PKG)-$(ARCH)" \
					"$(PKG_DIR)/$(PKG)-$(CONFIG)" \
					"$(PKG_DIR)/$(PKG)-$(ARCH)-$(CONFIG)"
SOURCES += $(foreach dir, $(PKG_RESOURCE_DIR), $(if $(wildcard $(dir)/sources.list), $(dir)/sources.list,))
SOURCES := $(filter-out ,$(SOURCES))

$(WORK_DIR):
	rm -rf $(PKG_WORK_DIR)

$(PKG_WORK_DIR): $(KILLER) $(WORK_DIR)
	mkdir "$@"
	cp -arfTL $(PKG_RESOURCE_DIR) "$@"
	cat $(SOURCES) >"$@/sources.list"
	cd "$@";$(KILLER) init -f;
	make -C "$@" config PKG=$(PKG) $(ARGS)

build: $(PKG_WORK_DIR)
	make -C $(PKG_WORK_DIR) test

push:
	git -C $(PKG_WORK_DIR) pull --rebase
	git -C $(PKG_WORK_DIR) add $(PKG)
	git -C $(PKG_WORK_DIR) diff --cached --quiet || git -C $(PKG_WORK_DIR) commit -m "Update $(PKG)"
	git push origin artifacts

upload: build
ifneq ($(FTP_URL),)
	echo "Uploading to $(FTP_URL)"
	curl -T $(PKG_WORK_DIR)/*.layer $(FTP_URL)
endif
ifneq ($(SCP_URL),)
	echo "Uploading to $(FTP_URL)"
	scp $(PKG_WORK_DIR)/*.layer $(SCP_URL)
endif

all: build push upload

.PHONY: all build push upload
.DEFAULT_GOAL := all 
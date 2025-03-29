include common/env.mk
include common/ll-killer.mk
SHELL=/bin/bash

PKGID ?=
TARGET:= $(basename $(notdir $(wildcard config/*.mk)))
MAX_TASKS?=10

TARGET_INDEX:=$(foreach item,$(TARGET),$(CACHE_DIR)/$(item).index)

$(CACHE_DIR)/%.index: $(CONFIG_DIR)/%.mk
	mkdir -p $(CACHE_DIR)
	make -f $(CONFIG_DIR)/$*.mk index INDEX=$@ CONFIG=$* ARCH=$(ARCH) || touch $@

$(PKG_INDEX): $(TARGET_INDEX)
	cat $(TARGET_INDEX)|"$(PWD)/scripts/compare.sh"| sort -u | tee  "$@~"
	mv "$@~" "$@"

index: $(PKG_INDEX)

CHECK_PKGID=$(if $(PKGID),,$(error "未提供PKGID参数"))
READ_CONFIG=IFS=, read -r PKGID VERSION CONFIG URL FILENAME <<<$$(awk -F, -v pkgid="$(PKGID)" '$$1 == pkgid {print $$0}' "$(PKG_INDEX)")
build test: 
	$(CHECK_PKGID)
	$(READ_CONFIG);\
	make -f common/build.mk $@ "PKGID=$$PKGID" "CONFIG=$$CONFIG" "URL=$$URL" "FILENAME=$$FILENAME" "VERSION=$$VERSION"

base:
	$(CHECK_PKGID)
	$(READ_CONFIG);\
	make -f $(CONFIG_DIR)/$$CONFIG.mk show-base

tasks: 
	./scripts/check.sh "$(PKG_INDEX)" | head -n $(MAX_TASKS) |jq -R .| jq -s . >tasks.json

.PHONY: index build tasks base test
.DEFAULT_GOAL := index 
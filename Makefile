include common/env.mk
include common/ll-killer.mk
SHELL=/bin/bash

PKGID ?=
TARGET:= $(basename $(notdir $(wildcard config/*.mk)))


TARGET_INDEX:=$(foreach item,$(TARGET),$(PKG_DIR)/$(item).index)

$(PKG_DIR)/%.index: $(CONFIG_DIR)/%.mk
	make -f $(CONFIG_DIR)/$*.mk index INDEX=$@ CONFIG=$*

index: $(TARGET_INDEX)
	cat $(TARGET_INDEX)|"$(PWD)/scripts/compare.sh"| sort -u | tee  "$(PKG_INDEX)~"
	mv "$(PKG_INDEX)~" "$(PKG_INDEX)"

MAKE_BUILD=IFS=, read -r PKGID VERSION CONFIG URL FILENAME <<<$$(grep -P "^$(PKGID)," "$(PKG_INDEX)" );\
	make -f common/build.mk $@ "PKGID=$$PKGID" "CONFIG=$$CONFIG" "URL=$$URL" "FILENAME=$$FILENAME" "VERSION=$$VERSION"
CHECK_PKGID=$(if $(PKGID),,$(error "未提供PKGID参数"))
build test upload push: $(PKG_INDEX)
	$(CHECK_PKGID)
	$(MAKE_BUILD)

push-index: $(TARGET_INDEX)
	git add $(PKG_INDEX)
	git diff --cached --quiet || git commit -m "Update Index"
	git pull --rebase && git push

base:
	$(CHECK_PKGID)
	IFS=, read -r PKGID VERSION CONFIG URL FILENAME <<<$$(grep -P "^$(PKGID)," "$(PKG_INDEX)" );\
	make -f $(CONFIG_DIR)/$$CONFIG.mk show-base

tasks: 
	./scripts/check.sh "$(PKG_INDEX)" | tail -n +1 | head -n 200 |jq -R .| jq -s . >tasks.json

.PHONY: index build tasks base test upload push push-index
.DEFAULT_GOAL := index 
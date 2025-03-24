include common/env.mk
include common/ll-killer.mk

PKG ?=
TARGET:= $(basename $(notdir $(wildcard config/*.mk)))

TARGET_INDEX:=$(foreach item,$(TARGET),$(PKG_DIR)/$(item).index)

$(PKG_DIR)/%.index: $(CONFIG_DIR)/%.mk
	make -f $(CONFIG_DIR)/$*.mk index INDEX=$@ CONFIG=$*

index: $(TARGET_INDEX)
	cat $(TARGET_INDEX)|"$(PWD)/scripts/compare.sh"| sort -u | tee  "$(PKG_INDEX)~"
	mv "$(PKG_INDEX)~" "$(PKG_INDEX)"

$(PKG_INDEX): index

build: $(PKG_INDEX)
	grep -P "^$(PKG),"|IFS=, read -r PKG VERSION CONFIG;\
	make -f common/build.mk "PKG=$$PKG" "CONFIG=$$CONFIG"

push: $(TARGET_INDEX)
	git pull --rebase
	git add .
	git -C $(PKG_WORK_DIR) commit -m "Update Index"
	git push origin main

tasks: $(PKG_INDEX)
	./scripts/check.sh "$(PKG_INDEX)" |jq -R .| jq -s . >tasks.json

.PHONY: index build push tasks
.DEFAULT_GOAL := index 
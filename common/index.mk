include common/env.mk
include common/ll-killer.mk

CONFIG?=
ARCH?=
SOURCES?=

TARGET_INDEX=$(INDEX)
TARGET_APT_DIR=$(CACHE_DIR)/$(CONFIG)

index: $(KILLER)
	mkdir -p $(TARGET_APT_DIR)
	cat $(SOURCES) >$(TARGET_APT_DIR)/sources.list
	set -e;\
	cd $(TARGET_APT_DIR);\
	$(KILLER) init -f;\
	$(KILLER) apt -- apt update -y && \
	$(KILLER) apt -- "$(PWD)/scripts/generate.sh" "$(CONFIG)"|tee "$(TARGET_INDEX)~";
	mv "$(TARGET_INDEX)~" "$(TARGET_INDEX)"

.PHONY: build
.DEFAULT_GOAL := build 
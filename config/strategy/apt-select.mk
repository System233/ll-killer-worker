include common/env.mk
include common/ll-killer.mk

CONFIG?=
ARCH?=
SOURCES?=
SELECT?=

TARGET_INDEX=$(INDEX)
TARGET_APT_DIR=$(CACHE_DIR)/$(CONFIG)

$(TARGET_INDEX): $(KILLER)
	mkdir -p $(TARGET_APT_DIR)
	cat $(SOURCES) >$(TARGET_APT_DIR)/sources.list
	set -e;\
	cd $(TARGET_APT_DIR);\
	$(KILLER) init -f;\
	$(KILLER) apt -- apt update -y && \
	$(KILLER) apt -- "$(PWD)/scripts/select.sh" "$(CONFIG)" $(SELECT) |tee "$@~";
	mv "$@~" "$@"

INDEX_TARGET=$(TARGET_INDEX)
include config/strategy/base.mk
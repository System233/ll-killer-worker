BASE?=org.deepin.base/23.1.0
CREATE_ARGS+=--base $(BASE)
ARGS+= CREATE_ARGS="$(CREATE_ARGS)" BUILD_ARGS="$(BUILD_ARGS)" ENABLE_OSTREE=1 ENABLE_TEST_NOCLI=1 ENABLE_PTRACE=1
show-base:
	@echo $(BASE)

ifneq ($(ARCH_FILTER),)
ifeq ($(filter $(ARCH), $(ARCH_FILTER)),)
INDEX_TARGET=
endif
endif

index: $(INDEX_TARGET)
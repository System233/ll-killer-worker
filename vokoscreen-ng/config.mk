PKG ?= vokoscreen-ng
APPID ?= vokoscreen-ng.linyaps
KILLER_EXEC ?= 
CREATE_ARGS ?= --base org.deepin.base/23.1.0
BUILD_ARGS ?= 
ENABLE_LDD_CHECK ?= 1
ENABLE_PTRACE ?= 1
ENABLE_INSTALL ?= 1
ENABLE_OSTREE ?= 1
ENABLE_TEST_NOCLI ?= 1
ENABLE_RM_DESKTOP ?= 1
LDD_CHECK_MODE ?= fast
UPDATE_TARGET ?= apt-update.log
INSTALL_TARGET ?= apt-install.log
EXTRA_BUILD ?= ./build.sh
EXTRA_POST_BUILD ?= ./post-build.sh
BUILD_TARGET ?= build.log
POST_BUILD_TARGET ?= post-build.log
PKG_INFO ?= pkg.info
YAML_CONFIG ?= linglong.yaml
EXTRA_DEPS ?= deps.list
LDD_CHECK_TARGET ?= ldd-check.log
LDD_NOTFOUND_TARGET ?= ldd-notfound.log
LDD_FOUND_TARGET ?= ldd-found.log
LDD_SEARCH_TARGET ?= ldd-found.log ldd-notfound.log
LDD_INSTALL_TARGET ?= apt-install-extra.log

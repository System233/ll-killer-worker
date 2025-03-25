SOURCES=config/sources/ubuntu-noble.list
BASE=org.deepin.base/23.1.0
ARGS= CREATE_ARGS="--base $(BASE)" ENABLE_OSTREE=1 ENABLE_PTRACE=0

include config/strategy/base.mk
include config/strategy/index.mk
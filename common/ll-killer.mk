KILLER ?= ll-killer

export PATH := $(PATH):$(PWD)
$(KILLER):
	wget -nv https://github.com/System233/ll-killer-go/releases/latest/download/ll-killer-$(ARCH) -O $@~
	chmod +x $@~
	mv $@~ $@
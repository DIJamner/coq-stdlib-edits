default_target: all

.PHONY: clean force all clean_all clone_all update_all clean_deps deps

# absolute paths so that emacs compile mode knows where to find error
# use cygpath -m because Coq on Windows cannot handle cygwin paths
ABS_ROOT_DIR := $(shell cygpath -m "$$(pwd)" 2>/dev/null || pwd)
SRC_DIR := $(ABS_ROOT_DIR)/src

COQC ?= "$(COQBIN)coqc"
COQ_VERSION:=$(shell $(COQC) --print-version | cut -d " " -f 1)

SRC_VS ?= $(shell find $(SRC_DIR) -type f -name '*.v')

define COQPROJECT
-R $(SRC_DIR)/Std Std

endef
export COQPROJECT

#TODO: build this automatically
_CoqProject:
	printenv COQPROJECT > _CoqProject

#TODO: build dependencies


clone_all:
	git submodule update --init --recursive

update_all:
	git submodule update --recursive

all: Makefile.coq $(SRC_VS)
	$(MAKE) -f Makefile.coq

COQ_MAKEFILE := $(COQBIN)coq_makefile -f _CoqProject -docroot Std $(COQMF_ARGS)

deps:

Makefile.coq: deps force _CoqProject
	@echo "Generating Makefile.coq"
	@$(COQ_MAKEFILE) $(SRC_VS) -o Makefile.coq

force:


clean: Makefile.coq
	$(MAKE) -f Makefile.coq clean
	find . -type f \( -name '*~' -o -name '*.glob' -o -name '*.aux' -o -name '.lia.cache' -o -name '.nia.cache' \) -delete
	rm -f Makefile.coq Makefile.coq.conf _CoqProject

clean_deps: 

clean_all: clean_deps clean

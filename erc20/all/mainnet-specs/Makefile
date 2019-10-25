#
# Parameters

NPROCS?=2
TIMEOUT?=10m

#
# Settings

MAKEFILE_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ROOT:=$(abspath $(MAKEFILE_DIR)/../../..)
RELATIVE_CURDIR:=$(strip $(patsubst $(ROOT)/%, %, $(filter $(ROOT)/%, $(CURDIR))))
SPECS_DIR:=$(ROOT)/specs
FRAGMENT_INI_FILES:=$(sort $(wildcard ../fragments/*.ini))
MAIN_INI_FILES:=$(sort $(wildcard *.ini))
SPEC_INI_FILES:=$(patsubst %.ini, $(SPECS_DIR)/$(RELATIVE_CURDIR)/%/erc20-spec.ini, $(MAIN_INI_FILES))

#
# Tasks

.PHONY: concat concat-test clean

concat-test: $(SPEC_INI_FILES:=.concat-test)

# Makes $(SPEC_INI_FILES) non-intermediary
concat: $(SPEC_INI_FILES)

clean:
	rm -rf $(SPECS_DIR)

%/erc20-spec.ini:
	mkdir -p $(dir $@)
	cat $(FRAGMENT_INI_FILES) $(MAKEFILE_DIR)/$(notdir $*).ini > $@

$(SPECS_DIR)/%/erc20-spec.ini.concat-test: $(SPECS_DIR)/%/erc20-spec.ini
	$(MAKE) -f run-spec.mak all                  SPEC_GROUP=$* SPEC_INI=$(basename $@)
	$(MAKE) -f run-spec.mak test                 SPEC_GROUP=$* SPEC_INI=$(basename $@) TIMEOUT=$(TIMEOUT) -i -j$(NPROCS)

#
# VSC-wide Settings
#

# path to this file
THIS_FILE:=$(abspath $(lastword $(MAKEFILE_LIST)))
# path to root directory
ROOT:=$(abspath $(dir $(THIS_FILE))/..)

# path to default directory that contains .k.rev and .kevm.rev
ROOT_BUILD_DIR:=$(ROOT)/.build

# java or haskell
K_BACKEND?=java

RESOURCES:=$(ROOT)/resources
SPECS_DIR:=$(ROOT)/specs/$(K_BACKEND)

#
# Backend Settings
#

K_MVN_OPTS_java:=-Dllvm.backend.skip -Dhaskell.backend.skip
K_MVN_OPTS_haskell:=-Dllvm.backend.skip

#
# Parameters
#

K_REPO_URL?=https://github.com/kframework/k
KEVM_REPO_URL?=https://github.com/kframework/evm-semantics

# Current dir path suffix after $(ROOT), if $(ROOT) is prefix of $(CURDIR)
SPEC_GROUP?=$(strip $(patsubst $(ROOT)/%, %, $(filter $(ROOT)/%, $(CURDIR))))
ifndef SPEC_GROUP
$(error SPEC_GROUP is not set)
endif

SPEC_INI?=$(strip $(wildcard *-spec.ini))
ifneq ($(words $(SPEC_INI)), 1)
$(error SPEC_INI should have 1 element. Actual value: $(SPEC_INI))
endif

ifndef SPEC_NAMES
$(error SPEC_NAMES is not set)
endif

# List of .k and .md lemma files that will be compiled to base directory of $(SPECS_DIR)/$(SPEC_GROUP)
BASEDIR_LEMMAS?=$(RESOURCES)/lemmas.md
# List of .k and .md lemma files that will be compiled to $(SPECS_DIR)/$(SPEC_GROUP)
LOCAL_LEMMAS?=../resources/abstract-semantics-direct-gas.k ../resources/evm-direct-gas.k \
              ../resources/evm-data-map-concrete.k verification.k
TMPLS?=module-tmpl.k spec-tmpl.k

# additional options to kprove command
KPROVE_OPTS?=
KPROVE_OPTS+=$(EXT_KPROVE_OPTS)

# Define variable DEBUG to enable debug options below
# DEBUG=true
ifdef DEBUG
KPROVE_OPTS+=--debug-z3-queries --log-rules
endif

# Example: 10ms/10s/10m/10h
TIMEOUT?=
# Above format
SHUTDOWN_WAIT_TIME?=5s

#
# Settings
#

K_VERSION_FILE   ?=$(ROOT_BUILD_DIR)/.k.rev
KEVM_VERSION_FILE?=$(ROOT_BUILD_DIR)/.kevm.rev
CONCRETE_RULES_FILE?=$(wildcard $(abspath $(dir $(KEVM_VERSION_FILE)))/concrete-rules.txt)
# check if the build directory exists (note: $(wildcard $(BUILD_DIR)) is not enough since it doesn't check if it is a directory)
ifeq ($(wildcard $(K_VERSION_FILE)),)
$(error K_VERSION_FILE does not exist)
endif
ifeq ($(wildcard $(KEVM_VERSION_FILE)),)
$(error KEVM_VERSION_FILE does not exist)
endif

K_VERSION        :=$(shell cat $(K_VERSION_FILE))
KEVM_VERSION     :=$(shell cat $(KEVM_VERSION_FILE))

K_REPO_DIR:=$(abspath $(dir $(K_VERSION_FILE))/k)
KEVM_REPO_DIR:=$(abspath $(dir $(KEVM_VERSION_FILE))/evm-semantics)
KEVM_BUILD_LAST_DIR:=$(K_BACKEND)
KEVM_BUILD_DIR:=$(KEVM_REPO_DIR)/.build/defn/$(KEVM_BUILD_LAST_DIR)

K_BIN:=$(abspath $(K_REPO_DIR)/k-distribution/target/release/k/bin)

DEFINITION_MODULE?=VERIFICATION

ifneq ($(SHUTDOWN_WAIT_TIME),)
  SHUTDOWN_WAIT_TIME_OPT:=--shutdown-wait-time $(SHUTDOWN_WAIT_TIME)
endif

ifneq ($(TIMEOUT),)
  TIMEOUT_OPT:=--timeout $(TIMEOUT)
endif

ifneq ($(CONCRETE_RULES_FILE),)
  CONCRETE_RULES_OPT:=--concrete-rules $(shell cat $(CONCRETE_RULES_FILE) | tr '\n' ',')
endif

KPROVE_PREFIX?=

KPROVE_OPTS_java:=--deterministic-functions --cache-func-optimized --format-failures --boundary-cells k,pc \
				  --log-cells k,output,statusCode,localMem,pc,gas,wordStack,callData,accounts,memoryUsed,\#pc,\#result
KPROVE_OPTS_haskell:=

KPROVE:=$(KPROVE_PREFIX) $(K_BIN)/kprove -v --debug -d $(KEVM_BUILD_DIR) -m $(DEFINITION_MODULE) \
        --z3-impl-timeout 500 $(SHUTDOWN_WAIT_TIME_OPT) $(TIMEOUT_OPT) $(CONCRETE_RULES_OPT) \
        --no-exc-wrap --no-alpha-renaming \
        $(KPROVE_OPTS_$(K_BACKEND)) $(KPROVE_OPTS)

KSERVER_LOG_FILE:=$(SPECS_DIR)/$(SPEC_GROUP)/kserver.log
SPAWN_KSERVER:=$(K_BIN)/kserver >> "$(KSERVER_LOG_FILE)" 2>&1 &
STOP_KSERVER:=$(K_BIN)/stop-kserver || true

SPEC_LOCAL_DIR:=$(SPECS_DIR)/$(SPEC_GROUP)
SPEC_FILES:=$(patsubst %,$(SPEC_LOCAL_DIR)/%-spec.k,$(SPEC_NAMES))
SPEC_BASEDIR:=$(abspath $(dir $(SPEC_LOCAL_DIR)))
BASEDIR_LEMMAS_TIMESTAMP:=$(SPEC_BASEDIR)/basedir-lemmas.timestamp
LOCAL_LEMMAS_TIMESTAMP:=$(SPEC_LOCAL_DIR)/lemmas.timestamp
LEMMAS:=$(BASEDIR_LEMMAS_TIMESTAMP) $(LOCAL_LEMMAS_TIMESTAMP)

PANDOC_TANGLE_SUBMODULE:=$(ROOT)/.build/pandoc-tangle
PANDOC_TANGLE_TIMESTAMP:=$(PANDOC_TANGLE_SUBMODULE)/submodule.timestamp
TANGLER:=$(PANDOC_TANGLE_SUBMODULE)/tangle.lua
LUA_PATH:=$(PANDOC_TANGLE_SUBMODULE)/?.lua;;
export TANGLER
export LUA_PATH

#
# Dependencies - Java Backend
#

.PHONY: all clean clean-deps clean-k clean-kevm clean-kevm-cache deps deps-tangle deps-k deps-kevm split-proof-tests test

all: deps split-proof-tests

clean:
	rm -rf $(SPECS_DIR)

clean-deps: clean clean-k clean-kevm
clean-k:
	rm -rf $(K_REPO_DIR)
clean-kevm:
	rm -rf $(KEVM_REPO_DIR)
clean-kevm-cache:
	rm -rf $(KEVM_BUILD_DIR)/driver-kompiled/cache.bin

deps: deps-tangle deps-k deps-kevm
deps-tangle: $(PANDOC_TANGLE_TIMESTAMP)
deps-k:      $(K_REPO_DIR)/mvn-$(K_BACKEND).timestamp
deps-kevm:   $(KEVM_REPO_DIR)/make-$(KEVM_BUILD_LAST_DIR).timestamp

%/submodule.timestamp:
	git submodule update --init --recursive -- $*
	touch $@

$(K_REPO_DIR)/mvn-$(K_BACKEND).timestamp: $(K_VERSION_FILE) | $(K_REPO_DIR)
	cd $(K_REPO_DIR) \
		&& git fetch \
		&& git reset --hard $(K_VERSION) \
		&& git submodule update --init --recursive \
		&& mvn package -DskipTests $(K_MVN_OPTS_$(K_BACKEND))
	touch $@

$(K_REPO_DIR):
	git clone $(K_REPO_URL) $(K_REPO_DIR)

KOMPILE_COMMAND?=$(MAKE) build-$(K_BACKEND) K_BIN=$(K_BIN)

$(KEVM_REPO_DIR)/make-$(KEVM_BUILD_LAST_DIR).timestamp: $(KEVM_VERSION_FILE) $(K_REPO_DIR)/mvn-$(K_BACKEND).timestamp | $(KEVM_REPO_DIR)
	cd $(KEVM_REPO_DIR) \
		&& git fetch \
		&& git clean -fdx \
		&& git reset --hard $(KEVM_VERSION) \
		&& make tangle-deps \
		&& make defn \
		&& $(KOMPILE_COMMAND)
	touch $@

$(KEVM_REPO_DIR):
	git clone $(KEVM_REPO_URL) $(KEVM_REPO_DIR)

#
# Specs
#

# makes all these files non-intermediary
split-proof-tests: $(SPEC_FILES) $(LEMMAS)

$(BASEDIR_LEMMAS_TIMESTAMP): $(BASEDIR_LEMMAS) $(PANDOC_TANGLE_TIMESTAMP)
	mkdir -p $(SPEC_BASEDIR)
	#processing .k lemmas
ifneq ($(wildcard $(BASEDIR_LEMMAS:.md=.k)),)
	cp $(wildcard $(BASEDIR_LEMMAS:.md=.k)) $(SPEC_BASEDIR)
endif
	#processing .md lemmas
	for i in $(wildcard $(BASEDIR_LEMMAS:.k=.md)); do \
		pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $$i > $(SPEC_BASEDIR)/"$$(basename $$i .md)".k; \
	done
	touch $@

$(LOCAL_LEMMAS_TIMESTAMP): $(LOCAL_LEMMAS) $(PANDOC_TANGLE_TIMESTAMP)
	mkdir -p $(SPEC_LOCAL_DIR)
	#processing .k local lemmas
ifneq ($(wildcard $(LOCAL_LEMMAS:.md=.k)),)
	cp $(wildcard $(LOCAL_LEMMAS:.md=.k)) $(SPEC_LOCAL_DIR)
endif
	#processing .md local lemmas
	for i in $(wildcard $(LOCAL_LEMMAS:.k=.md)); do \
		pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $$i > $(SPEC_LOCAL_DIR)/"$$(basename $$i .md)".k; \
	done
	touch $@

ifneq ($(wildcard $(SPEC_INI:.ini=.md)),)
$(SPEC_INI): $(SPEC_INI:.ini=.md) $(PANDOC_TANGLE_TIMESTAMP)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".ini" $< > $@
endif

# When building a -spec.k file, build all run dependencies.
$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k: $(TMPLS) $(SPEC_INI) $(LEMMAS)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) $* $* > $@

#
# Kprove
#

test: $(addsuffix .test,$(SPEC_FILES))

$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k.test: $(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k
	$(KPROVE) $<

spawn-kserver:
	mkdir -p "$(dir $(KSERVER_LOG_FILE))"
	$(SPAWN_KSERVER)

stop-kserver:
	$(STOP_KSERVER)

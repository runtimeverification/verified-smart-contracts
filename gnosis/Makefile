# Settings
# --------

specs_dir:=specs
build_dir:=.build
resources:=../resources

K_VERSION   :=$(shell cat ${build_dir}/.k.rev)
KEVM_VERSION:=$(shell cat ${build_dir}/.kevm.rev)

.PHONY: all all-dev clean k kevm clean-kevm

all: k-files split-proof-tests

all-dev: all split-proof-tests-dev

clean:
	rm -rf $(specs_dir) $(build_dir)/*

pandoc_tangle_submodule:=../$(build_dir)/pandoc-tangle
TANGLER:=$(pandoc_tangle_submodule)/tangle.lua
LUA_PATH:=$(pandoc_tangle_submodule)/?.lua;;
export LUA_PATH

$(TANGLER):
	git submodule update --init -- $(pandoc_tangle_submodule)

k_repo:=https://github.com/kframework/k
k_repo_dir:=$(build_dir)/k
k_bin:=$(shell pwd)/$(k_repo_dir)/k-distribution/target/release/k/bin

k:
	git clone $(k_repo) $(k_repo_dir)
	cd $(k_repo_dir) \
		&& git reset --hard $(K_VERSION) \
		&& mvn package -DskipTests

kevm_repo:=https://github.com/kframework/evm-semantics
kevm_repo_dir:=$(build_dir)/evm-semantics

kevm:
	git clone $(kevm_repo) $(kevm_repo_dir)
	cd $(kevm_repo_dir) \
		&& git reset --hard $(KEVM_VERSION) \
		&& make tangle-deps \
		&& make defn \
		&& $(k_bin)/kompile -v --debug --backend java -I .build/java -d .build/java --main-module ETHEREUM-SIMULATION --syntax-module ETHEREUM-SIMULATION .build/java/driver.k


# Definition Files
# ----------------

k_files:=lemmas.k

k-files: $(patsubst %, $(specs_dir)/%, $(k_files))

# Lemmas
$(specs_dir)/lemmas.k: $(resources)/lemmas.md $(TANGLER)
	@echo >&2 "== tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $< > $@

# Spec Files
# ----------

gnosis_files:=encodeTransactionData-data32-spec.k \
              encodeTransactionData-data33-spec.k

gnosis_test_files:=testKeccak-data1-spec.k \
                   testKeccak-data32-spec.k \
                   testKeccak-data33-spec.k \
                   testAbiEncode-spec.k \
                   testAbiEncode-AndKeccak-data1-spec.k \
                   testAbiEncodePacked-spec.k \
                   testSignatureSplit-pos0-spec.k \
                   testSignatureSplit-pos1-spec.k \
                   testSignatureSplit-pos2-spec.k \
                   testEcrecover-non-empty-spec.k \
                   testEcrecover-empty-spec.k

proof_tests:=

proof_tests_dev:=$(proof_tests) gnosis gnosis-test

split-proof-tests: $(proof_tests)

split-proof-tests-dev: $(proof_tests_dev)

gnosis: $(patsubst %, $(specs_dir)/gnosis/%, $(gnosis_files)) $(specs_dir)/lemmas.k

gnosis-test: $(patsubst %, $(specs_dir)/gnosis-test/%, $(gnosis_test_files)) $(specs_dir)/lemmas.k

# Gnosis
gnosis_tmpls:=module-tmpl.k spec-tmpl.k

$(specs_dir)/gnosis/%-spec.k: $(gnosis_tmpls) gnosis-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 $(resources)/gen-spec.py $^ $* $* > $@
	cp abstract-semantics.k $(dir $@)
	cp verification.k $(dir $@)

$(specs_dir)/gnosis/execTransactionAndPaySubmitter-example-spec.k: $(gnosis_tmpls) gnosis-spec.ini
	@echo >&2 "==  gen-spec: $@"
	python3 $(resources)/gen-spec.py $^ execTransactionAndPaySubmitter-example checkHash execTransactionAndPaySubmitter-example > $@

# Gnosis Test
gnosis_test_tmpls:=module-tmpl.k spec-tmpl.k

$(specs_dir)/gnosis-test/%-spec.k: $(gnosis_test_tmpls) test/api-test.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 $(resources)/gen-spec.py $^ $* $* > $@
	cp abstract-semantics.k $(dir $@)
	cp verification.k $(dir $@)


# Testing
# -------

TEST:=$(k_bin)/kprove -v -d $(kevm_repo_dir)/.build/java -m VERIFICATION --z3-executable --z3-impl-timeout 500

test_files:=$(wildcard specs/*/*-spec.k)

test: $(test_files:=.test)

specs/%-spec.k.test: specs/%-spec.k
	$(TEST) $<

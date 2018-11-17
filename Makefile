# Settings
# --------

specs_dir:=specs
build_dir:=.build

K_VERSION   :=$(shell cat ${build_dir}/.k.rev)
KEVM_VERSION:=$(shell cat ${build_dir}/.kevm.rev)

.PHONY: all all-dev clean k kevm clean-kevm

all: k-files split-proof-tests

all-dev: all split-proof-tests-dev

clean:
	rm -rf $(specs_dir) $(build_dir)/*

pandoc_tangle_submodule:=$(build_dir)/pandoc-tangle
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
$(specs_dir)/lemmas.k: resources/lemmas.md $(TANGLER)
	@echo >&2 "== tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $< > $@

# Spec Files
# ----------

bihu_collectToken_file:=collectToken-spec.k

bihu_forwardToHotWallet_files:=forwardToHotWallet-success-1-spec.k \
                               forwardToHotWallet-success-2-spec.k \
                               forwardToHotWallet-failure-1-spec.k \
                               forwardToHotWallet-failure-2-spec.k \
                               forwardToHotWallet-failure-3-spec.k \
                               forwardToHotWallet-failure-4-spec.k

erc20_files:=totalSupply-spec.k \
             balanceOf-spec.k \
             allowance-spec.k \
             approve-spec.k \
             transfer-success-1-spec.k \
             transfer-success-2-spec.k \
             transfer-failure-1-spec.k \
             transfer-failure-2-spec.k \
             transferFrom-success-1-spec.k \
             transferFrom-success-2-spec.k \
             transferFrom-failure-1-spec.k \
             transferFrom-failure-2-spec.k

zeppelin_erc20_files:=totalSupply-spec.k \
             balanceOf-spec.k \
             allowance-spec.k \
             approve-spec.k \
             transfer-success-1-spec.k \
             transfer-success-2-spec.k \
             transfer-failure-1-a-spec.k \
             transfer-failure-1-b-spec.k \
             transfer-failure-2-spec.k \
             transferFrom-success-1-spec.k \
             transferFrom-success-2-spec.k \
             transferFrom-failure-1-a-spec.k \
             transferFrom-failure-1-b-spec.k \
             transferFrom-failure-2-spec.k

hobby_erc20_files:=totalSupply-spec.k \
                   balanceOf-spec.k \
                   allowance-spec.k \
                   approve-success-spec.k \
                   approve-failure-spec.k \
                   transfer-success-1-spec.k \
                   transfer-success-2-spec.k \
                   transfer-failure-1-spec.k \
                   transfer-failure-2-spec.k \
                   transferFrom-success-1-spec.k \
                   transferFrom-success-2-spec.k \
                   transferFrom-failure-1-spec.k \
                   transferFrom-failure-2-spec.k

ds_token_erc20_files:=totalSupply-spec.k \
                   balanceOf-spec.k \
                   allowance-spec.k \
                   approve-success-spec.k \
                   approve-failure-spec.k \
                   transfer-success-1-spec.k \
                   transfer-success-2-spec.k \
                   transfer-failure-1-a-spec.k \
                   transfer-failure-1-b-spec.k \
                   transfer-failure-1-c-spec.k \
                   transfer-failure-2-a-spec.k \
                   transfer-failure-2-b-spec.k \
                   transferFrom-success-1-spec.k \
                   transferFrom-success-2-spec.k \
                   transferFrom-failure-1-a-spec.k \
                   transferFrom-failure-1-b-spec.k \
                   transferFrom-failure-1-c-spec.k \
                   transferFrom-failure-1-d-spec.k \
                   transferFrom-failure-2-a-spec.k \
                   transferFrom-failure-2-b-spec.k \
                   transferFrom-failure-2-c-spec.k

casper_files:=recommended_source_epoch-spec.k \
              recommended_target_hash-success-spec.k \
              recommended_target_hash-failure-11-spec.k \
              recommended_target_hash-failure-12-spec.k \
              recommended_target_hash-failure-2-spec.k \
              deposit_exists-success-true-spec.k \
              deposit_exists-success-false-1-spec.k \
              deposit_exists-success-false-2-spec.k \
              deposit_exists-failure-spec.k \
              proc_reward-spec.k \
              vote-1-2-3-4-5-6-success-1-spec.k \
              vote-1-failure-1-spec.k \
              vote-1-failure-2-spec.k \
              vote-1-2-failure-1-spec.k \
              vote-1-2-failure-2-spec.k \
              vote-1-2-3-failure-1-spec.k \
              vote-1-2-3-failure-2-spec.k \
              vote-1-2-3-4-failure-1-spec.k \
              vote-1-2-3-4-failure-2-spec.k \
              vote-1-2-3-4-5-failure-1-spec.k \
              vote-1-2-3-4-5-failure-2-spec.k \
              delete_validator-success-spec.k \
              delete_validator-failure-spec.k \
              main_hash_voted_frac-success-1-spec.k \
              main_hash_voted_frac-success-2-spec.k \
              main_hash_voted_frac-failure-spec.k \
              total_curdyn_deposits_scaled-success-spec.k \
              total_curdyn_deposits_scaled-failure-1-spec.k \
              total_curdyn_deposits_scaled-failure-21-spec.k \
              total_curdyn_deposits_scaled-failure-22-spec.k \
              total_prevdyn_deposits_scaled-success-spec.k \
              total_prevdyn_deposits_scaled-failure-1-spec.k \
              total_prevdyn_deposits_scaled-failure-21-spec.k \
              total_prevdyn_deposits_scaled-failure-22-spec.k \
              deposit_size-success-spec.k \
              deposit_size-failure-1-spec.k \
              deposit_size-failure-21-spec.k \
              deposit_size-failure-22-spec.k \
              increment_dynasty-is_finalized-justified-spec.k \
              increment_dynasty-is_finalized-not-justified-spec.k \
              increment_dynasty-not-is_finalized-justified-spec.k \
              increment_dynasty-not-is_finalized-not-justified-spec.k \
              logout-failure-1-spec.k \
              logout-failure-2-spec.k \
              logout-12-failure-3-spec.k \
              logout-12-failure-4-spec.k \
              logout-12-34-failure-5-spec.k \
              logout-12-34-5-success-spec.k \
              esf-success-spec.k \
              esf-failure-spec.k \
              insta_finalize-success-spec.k \
              insta_finalize-failure-spec.k \
              collective_reward-success-normal-1-spec.k \
              collective_reward-success-normal-2-spec.k \
              collective_reward-success-zero-1-1-spec.k \
              collective_reward-success-zero-1-2-spec.k \
              collective_reward-success-zero-2-spec.k \
              collective_reward-failure-spec.k

gnosis_files:=encodeTransactionData-data32-spec.k \
              encodeTransactionData-data33-spec.k \
              checkSignatures-threshold-0-spec.k \
              checkSignatures-threshold-too-large-spec.k \
              checkSignatures-threshold-1-sigv-2-empty-spec.k \
              checkSignatures-threshold-1-sigv-2-ne-success-spec.k \
              checkSignatures-threshold-1-sigv-2-ne-notOwner-spec.k

# FIXME: restore the skipped specs
#             setupSafe-spec.k
#             swapOwner-spec.k
#             execTransactionAndPaySubmitter-spec.k
#             execTransactionAndPaySubmitter_data-spec.k
#             getTransactionHash-spec.k
#             checkHash-spec.k

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

proof_tests:=sum-to-n vyper-erc20 zeppelin-erc20

proof_tests_dev:=$(proof_tests) bihu hkg-erc20 hobby-erc20 ds-token-erc20 gnosis gnosis-test

# FIXME: restore the casper specs
#proof_tests_dev += casper

split-proof-tests: $(proof_tests)

split-proof-tests-dev: $(proof_tests_dev)

bihu: $(patsubst %, $(specs_dir)/bihu/%, $(bihu_collectToken_file)) $(patsubst %, $(specs_dir)/bihu/%, $(bihu_forwardToHotWallet_files)) $(specs_dir)/lemmas.k

vyper-erc20: $(patsubst %, $(specs_dir)/vyper-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

zeppelin-erc20: $(patsubst %, $(specs_dir)/zeppelin-erc20/%, $(zeppelin_erc20_files)) $(specs_dir)/lemmas.k

hkg-erc20: $(patsubst %, $(specs_dir)/hkg-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

hobby-erc20: $(patsubst %, $(specs_dir)/hobby-erc20/%, $(hobby_erc20_files)) $(specs_dir)/lemmas.k

sum-to-n: $(specs_dir)/examples/sum-to-n-spec.k $(specs_dir)/lemmas.k

ds-token-erc20: $(patsubst %, $(specs_dir)/ds-token-erc20/%, $(ds_token_erc20_files)) $(specs_dir)/lemmas.k

casper: $(patsubst %, $(specs_dir)/casper/%, $(casper_files)) $(specs_dir)/lemmas.k

gnosis: $(patsubst %, $(specs_dir)/gnosis/%, $(gnosis_files)) $(specs_dir)/lemmas.k

gnosis-test: $(patsubst %, $(specs_dir)/gnosis-test/%, $(gnosis_test_files)) $(specs_dir)/lemmas.k

# Bihu
bihu_tmpls:=bihu/module-tmpl.k bihu/spec-tmpl.k

$(specs_dir)/bihu/collectToken-spec.k: $(bihu_tmpls) bihu/collectToken-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ collectToken collectToken loop ds-math-mul > $@
	cp bihu/abstract-semantics.k $(dir $@)
	cp bihu/verification.k $(dir $@)

$(specs_dir)/bihu/forwardToHotWallet%-spec.k: $(bihu_tmpls) bihu/forwardToHotWallet-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $(addsuffix $*, forwardToHotWallet) $(addsuffix $*, forwardToHotWallet) > $@
	cp bihu/abstract-semantics.k $(dir $@)
	cp bihu/verification.k $(dir $@)

# ERC20
erc20_tmpls:=erc20/module-tmpl.k erc20/spec-tmpl.k

$(specs_dir)/vyper-erc20/%-spec.k: $(erc20_tmpls) erc20/vyper/vyper-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/zeppelin-erc20/%-spec.k: $(erc20_tmpls) erc20/zeppelin/zeppelin-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/hkg-erc20/%-spec.k: $(erc20_tmpls) erc20/hkg/hkg-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/hobby-erc20/%-spec.k: $(erc20_tmpls) erc20/hobby/hobby-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/ds-token-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/ds-token/ds-token-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

# Sum to N
$(specs_dir)/examples/sum-to-n-spec.k: resources/sum-to-n.md $(TANGLER)
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to "$(TANGLER)" --metadata="code:.sum-to-n" $< > $@

# Casper
casper_tmpls:=casper/module-tmpl.k casper/spec-tmpl.k

$(specs_dir)/casper/%-spec.k: $(casper_tmpls) casper/casper-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp casper/abstract-semantics.k $(dir $@)
	cp casper/verification.k $(dir $@)

$(specs_dir)/casper/vote-1-2-3-4-5-6-success-1-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-3-4-5-6-success-1 recommended_target_hash-success proc_reward vote-1-2-3-4-5-6-success-1 > $@

$(specs_dir)/casper/vote-1-2-failure-1-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-failure-1 recommended_target_hash-success vote-1-2-failure-1 > $@

$(specs_dir)/casper/vote-1-2-failure-2-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-failure-2 recommended_target_hash-success vote-1-2-failure-2 > $@

$(specs_dir)/casper/vote-1-2-3-failure-1-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-3-failure-1 recommended_target_hash-success vote-1-2-3-failure-1 > $@

$(specs_dir)/casper/vote-1-2-3-failure-2-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-3-failure-2 recommended_target_hash-success vote-1-2-3-failure-2 > $@

$(specs_dir)/casper/vote-1-2-3-4-failure-1-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-3-4-failure-1 recommended_target_hash-success vote-1-2-3-4-failure-1 > $@

$(specs_dir)/casper/vote-1-2-3-4-failure-2-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-3-4-failure-2 recommended_target_hash-success vote-1-2-3-4-failure-2 > $@

$(specs_dir)/casper/vote-1-2-3-4-5-failure-1-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-3-4-5-failure-1 recommended_target_hash-success vote-1-2-3-4-5-failure-1 > $@

$(specs_dir)/casper/vote-1-2-3-4-5-failure-2-spec.k: $(casper_tmpls) casper/casper-spec.ini
	python3 resources/gen-spec.py $^ vote-1-2-3-4-5-failure-2 recommended_target_hash-success vote-1-2-3-4-5-failure-2 > $@


$(specs_dir)/casper/collective_reward-success-normal-1-spec.k: $(casper_tmpls) casper/casper-spec.ini
	@echo >&2 "==  gen-spec: $@"
	python3 resources/gen-spec.py $^ collective_reward-success-normal-1 esf-success deposit_exists-success-true collective_reward-success-normal-1 > $@

$(specs_dir)/casper/collective_reward-success-normal-2-spec.k: $(casper_tmpls) casper/casper-spec.ini
	@echo >&2 "==  gen-spec: $@"
	python3 resources/gen-spec.py $^ collective_reward-success-normal-2 esf-success deposit_exists-success-true collective_reward-success-normal-2 > $@

$(specs_dir)/casper/collective_reward-success-zero-1-1-spec.k: $(casper_tmpls) casper/casper-spec.ini
	@echo >&2 "==  gen-spec: $@"
	python3 resources/gen-spec.py $^ collective_reward-success-zero-1-1 esf-success deposit_exists-success-true deposit_exists-success-false-1 deposit_exists-success-false-2 collective_reward-success-zero-1-1 > $@

$(specs_dir)/casper/collective_reward-success-zero-1-2-spec.k: $(casper_tmpls) casper/casper-spec.ini
	@echo >&2 "==  gen-spec: $@"
	python3 resources/gen-spec.py $^ collective_reward-success-zero-1-2 esf-success deposit_exists-success-true deposit_exists-success-false-1 deposit_exists-success-false-2 collective_reward-success-zero-1-2 > $@

$(specs_dir)/casper/collective_reward-success-zero-2-spec.k: $(casper_tmpls) casper/casper-spec.ini
	@echo >&2 "==  gen-spec: $@"
	python3 resources/gen-spec.py $^ collective_reward-success-zero-2 esf-success deposit_exists-success-true deposit_exists-success-false-1 deposit_exists-success-false-2 collective_reward-success-zero-2 > $@

# Gnosis
gnosis_tmpls:=gnosis/module-tmpl.k gnosis/spec-tmpl.k

$(specs_dir)/gnosis/%-spec.k: $(gnosis_tmpls) gnosis/gnosis-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp gnosis/abstract-semantics.k $(dir $@)
	cp gnosis/verification.k $(dir $@)

$(specs_dir)/gnosis/execTransactionAndPaySubmitter-example-spec.k: $(gnosis_tmpls) gnosis/gnosis-spec.ini
	@echo >&2 "==  gen-spec: $@"
	python3 resources/gen-spec.py $^ execTransactionAndPaySubmitter-example checkHash execTransactionAndPaySubmitter-example > $@

# Gnosis Test
gnosis_test_tmpls:=gnosis/module-tmpl.k gnosis/spec-tmpl.k

 $(specs_dir)/gnosis-test/%-spec.k: $(gnosis_test_tmpls) gnosis/test/api-test.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ $* $* > $@
	cp gnosis/abstract-semantics.k $(dir $@)
	cp gnosis/verification.k $(dir $@)


# Testing
# -------

TEST:=$(k_bin)/kprove -v -d $(kevm_repo_dir)/.build/java -m VERIFICATION --z3-executable --z3-impl-timeout 500

test_files:=$(wildcard specs/*/*-spec.k)

test: $(test_files:=.test)

specs/%-spec.k.test: specs/%-spec.k
	$(TEST) $<

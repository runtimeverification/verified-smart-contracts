# Settings
# --------

specs_dir:=specs
build_dir:=.build

.PHONY: all clean kevm clean-kevm

all: k-files split-proof-tests

clean:
	rm -rf $(specs_dir) $(build_dir)

pandoc_tangle_submodule:=$(build_dir)/pandoc-tangle
TANGLER:=$(pandoc_tangle_submodule)/tangle.lua
LUA_PATH:=$(pandoc_tangle_submodule)/?.lua;;
export LUA_PATH

$(TANGLER):
	git submodule update --init -- $(pandoc_tangle_submodule)

kevm_repo:=https://github.com/kframework/evm-semantics
kevm_repo_dir:=$(build_dir)/evm-semantics

kevm: clean-kevm
	git clone $(kevm_repo) --depth 1 $(kevm_repo_dir)
	cd $(kevm_repo_dir) \
		&& make deps \
		&& make build-java

clean-kevm:
	rm -rf $(kevm_repo_dir)

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

casper_files:=recommended_target_hash-spec.k \
              proc_reward-spec.k \
              vote-spec.k \
              delete_validator-spec.k \
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
              logout-12-34-5-success-pos-spec.k \
              logout-12-34-5-success-neg-spec.k \
              logout-12-34-5-success-spec.k

proof_tests:= bihu vyper-erc20 zeppelin-erc20 hkg-erc20 hobby-erc20 sum-to-n ds-token-erc20 casper


split-proof-tests: $(proof_tests)

bihu: $(patsubst %, $(specs_dir)/bihu/%, $(bihu_collectToken_file)) $(patsubst %, $(specs_dir)/bihu/%, $(bihu_forwardToHotWallet_files)) $(specs_dir)/lemmas.k

vyper-erc20: $(patsubst %, $(specs_dir)/vyper-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

zeppelin-erc20: $(patsubst %, $(specs_dir)/zeppelin-erc20/%, $(zeppelin_erc20_files)) $(specs_dir)/lemmas.k

hkg-erc20: $(patsubst %, $(specs_dir)/hkg-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

hobby-erc20: $(patsubst %, $(specs_dir)/hobby-erc20/%, $(hobby_erc20_files)) $(specs_dir)/lemmas.k

sum-to-n: $(specs_dir)/examples/sum-to-n-spec.k $(specs_dir)/lemmas.k

ds-token-erc20: $(patsubst %, $(specs_dir)/ds-token-erc20/%, $(ds_token_erc20_files)) $(specs_dir)/lemmas.k

casper: $(patsubst %, $(specs_dir)/casper/%, $(casper_files)) $(specs_dir)/lemmas.k

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

$(specs_dir)/casper/vote-spec.k: $(casper_tmpls) casper/casper-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 resources/gen-spec.py $^ vote recommended_target_hash proc_reward vote > $@
	cp casper/abstract-semantics.k $(dir $@)
	cp casper/verification.k $(dir $@)

# Testing
# -------

TEST:=$(kevm_repo_dir)/kevm prove

test_files:=$(wildcard specs/*/*-spec.k)

test: $(test_files:=.test)

specs/%-spec.k.test: specs/%-spec.k
	$(TEST) $<

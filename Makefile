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

proof_tests:= bihu vyper-erc20 zeppelin-erc20 hkg-erc20 hobby-erc20 sum-to-n

split-proof-tests: $(proof_tests)

bihu: $(patsubst %, $(specs_dir)/bihu/%, $(bihu_collectToken_file)) $(patsubst %, $(specs_dir)/bihu/%, $(bihu_forwardToHotWallet_files)) $(specs_dir)/lemmas.k

vyper-erc20: $(patsubst %, $(specs_dir)/vyper-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

zeppelin-erc20: $(patsubst %, $(specs_dir)/zeppelin-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

hkg-erc20: $(patsubst %, $(specs_dir)/hkg-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

hobby-erc20: $(patsubst %, $(specs_dir)/hobby-erc20/%, $(hobby_erc20_files)) $(specs_dir)/lemmas.k

sum-to-n: $(specs_dir)/examples/sum-to-n-spec.k $(specs_dir)/lemmas.k

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

# Sum to N
$(specs_dir)/examples/sum-to-n-spec.k: resources/sum-to-n.md $(TANGLER)
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to "$(TANGLER)" --metadata="code:.sum-to-n" $< > $@

# Testing
# -------

TEST:=$(kevm_repo_dir)/kevm prove

test_files:=$(wildcard specs/*/*-spec.k)

test: $(test_files:=.test)

specs/%-spec.k.test: specs/%-spec.k
	$(TEST) $<

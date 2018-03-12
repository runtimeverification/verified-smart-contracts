specs_dir:=specs

bihu_collectToken_file:=collectToken-spec.k \

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

ds_token_erc20_files:=totalSupply-spec.k \
                   balanceOf-spec.k \
                   allowance-spec.k \
                   approve-success-spec.k \
                   approve-failure-spec.k \
                   transfer-success-1-spec.k \
                   transfer-success-2-spec.k \
                   transfer-failure-1-a-spec.k \
                   transfer-failure-2-a-spec.k \
                   transfer-failure-1-b-spec.k \
                   transfer-failure-2-b-spec.k \
                   transfer-failure-1-c-spec.k \
                   transferFrom-success-1-spec.k \
                   transferFrom-success-2-spec.k \
                   transferFrom-failure-1-a-spec.k \
                   transferFrom-failure-2-a-spec.k \
                   transferFrom-failure-1-b-spec.k \
                   transferFrom-failure-2-b-spec.k \
                   transferFrom-failure-1-c-spec.k \
                   transferFrom-failure-2-c-spec.k \
                   transferFrom-failure-1-d-spec.k

proof_tests:= bihu vyper-erc20 zeppelin-erc20 hkg-erc20 hobby-erc20 sum-to-n ds-token-erc20

split-proof-tests: $(proof_tests)

bihu: $(patsubst %, $(specs_dir)/bihu/%, $(bihu_collectToken_file)) $(patsubst %, $(specs_dir)/bihu/%, $(bihu_forwardToHotWallet_files)) $(specs_dir)/lemmas.k

vyper-erc20: $(patsubst %, $(specs_dir)/vyper-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

zeppelin-erc20: $(patsubst %, $(specs_dir)/zeppelin-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

hkg-erc20: $(patsubst %, $(specs_dir)/hkg-erc20/%, $(erc20_files)) $(specs_dir)/lemmas.k

hobby-erc20: $(patsubst %, $(specs_dir)/hobby-erc20/%, $(hobby_erc20_files)) $(specs_dir)/lemmas.k

sum-to-n: $(specs_dir)/examples/sum-to-n-spec.k $(specs_dir)/lemmas.k

ds-token-erc20: $(patsubst %, $(specs_dir)/ds-token-erc20/%, $(ds_token_erc20_files)) $(specs_dir)/lemmas.k


# Definition Files
# ----------------

# Lemmas
$(specs_dir)/lemmas.k: resources/lemmas.md
	@echo >&2 "== tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $< > $@

# Spec Files
# ----------

# Bihu
$(specs_dir)/bihu/collectToken-spec.k: bihu/module-tmpl.k bihu/spec-tmpl.k bihu/collectToken-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ collectToken collectToken loop ds-math-mul > $@
	cp bihu/abstract-semantics.k $(dir $@)
	cp bihu/verification.k $(dir $@)

$(specs_dir)/bihu/forwardToHotWallet%-spec.k: bihu/module-tmpl.k bihu/spec-tmpl.k bihu/forwardToHotWallet-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $(addsuffix $*, forwardToHotWallet) $(addsuffix $*, forwardToHotWallet) > $@
	cp bihu/abstract-semantics.k $(dir $@)
	cp bihu/verification.k $(dir $@)

# ERC20
$(specs_dir)/vyper-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/vyper/vyper-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/zeppelin-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/zeppelin/zeppelin-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/hkg-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/hkg/hkg-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/hobby-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/hobby/hobby-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

$(specs_dir)/ds-token-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/ds-token/ds-token-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/abstract-semantics.k $(dir $@)
	cp erc20/verification.k $(dir $@)

# Sum to N
$(specs_dir)/examples/sum-to-n-spec.k: examples/sum-to-n/sum-to-n.md
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to "$(TANGLER)" --metadata="code:.sum-to-n" $< > $@

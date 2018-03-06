specs_dir:=specs

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

proof_tests:= vyper-erc20 zeppelin-erc20 hkg-erc20 hobby-erc20

split-proof-tests: $(proof_tests) $(specs_dir)/lemmas.k

vyper-erc20: $(patsubst %, $(specs_dir)/vyper-erc20/%, $(erc20_files))

zeppelin-erc20: $(patsubst %, $(specs_dir)/zeppelin-erc20/%, $(erc20_files))

hkg-erc20: $(patsubst %, $(specs_dir)/hkg-erc20/%, $(erc20_files))

hobby-erc20: $(patsubst %, $(specs_dir)/hobby-erc20/%, $(hobby_erc20_files))

$(specs_dir)/lemmas.k: resources/lemmas.k
	@echo >&2 "== copy lemmas.k"
	mkdir -p $(dir $@)
	cp $^ $@

# #### ERC20
$(specs_dir)/vyper-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/vyper/vyper-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/verification.k $(dir $@)

$(specs_dir)/zeppelin-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/zeppelin/zeppelin-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/verification.k $(dir $@)

$(specs_dir)/hkg-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/hkg/hkg-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/verification.k $(dir $@)

$(specs_dir)/hobby-erc20/%-spec.k: erc20/module-tmpl.k erc20/spec-tmpl.k erc20/hobby/hobby-erc20-spec.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20/verification.k $(dir $@)

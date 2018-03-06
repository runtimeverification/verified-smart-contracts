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

proof_tests:= erc20-viper erc20-zeppelin erc20-hkg erc20-hobby

split-proof-tests: $(proof_tests) $(specs_dir)/lemmas.k

erc20-viper: $(patsubst %, $(specs_dir)/erc20-viper/%, $(erc20_files))

erc20-zeppelin: $(patsubst %, $(specs_dir)/erc20-zeppelin/%, $(erc20_files))

erc20-hkg: $(patsubst %, $(specs_dir)/erc20-hkg/%, $(erc20_files))

erc20-hobby: $(patsubst %, $(specs_dir)/erc20-hobby/%, $(hobby_erc20_files))

$(specs_dir)/lemmas.k: resources/lemmas.k
	@echo >&2 "== copy lemmas.k"
	mkdir -p $(dir $@)
	cp $^ $@

# #### ERC20
$(specs_dir)/erc20-viper/%-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/viper/spec-viper.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20-dev/verification.k $(dir $@)

$(specs_dir)/erc20-zeppelin/%-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/zeppelin/spec-zeppelin.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20-dev/verification.k $(dir $@)

$(specs_dir)/erc20-hkg/%-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/hkg/spec-hkg.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20-dev/verification.k $(dir $@)

$(specs_dir)/erc20-hobby/%-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/hobby/spec-hobby.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ $* $* > $@
	cp erc20-dev/verification.k $(dir $@)

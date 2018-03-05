erc20_rules:=totalSupply \
             balanceOf \
             allowance \
             approve-spec \
             transfer-success-1 \
             transfer-success-2 \
             transfer-failure-1 \
             transfer-failure-2 \
             transferFrom-success-1 \
             transferFrom-success-2 \
             transferFrom-failure-1 \
             transferFrom-failure-2

erc20_hobby_rules:=totalSupply \
                   balanceOf \
                   allowance \
                   approve-success \
                   approve-failure \
                   transfer-success-1 \
                   transfer-success-2 \
                   transfer-failure-1 \
                   transfer-failure-2 \
                   transferFrom-success-1 \
                   transferFrom-success-2 \
                   transferFrom-failure-1 \
                   transferFrom-failure-2

specs_dir:=specs

erc20-viper: $(specs_dir)/erc20/viper-spec.k

erc20-zeppelin: $(specs_dir)/erc20/zeppelin-spec.k

erc20-hkg: $(specs_dir)/erc20/hkg-spec.k

erc20-hobby: $(specs_dir)/erc20/hobby-spec.k

split-proofs-tests: erc20-viper erc20-zeppelin erc20-hkg erc20-hobby

$(specs_dir)/erc20/viper-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/viper/spec-viper.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ viper $(erc20_rules) > $@

$(specs_dir)/erc20/zeppelin-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/zeppelin/spec-zeppelin.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ zeppelin $(erc20_rules) > $@

$(specs_dir)/erc20/hkg-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/hkg/spec-hkg.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ hkg $(erc20_rules) > $@

$(specs_dir)/erc20/hobby-spec.k: erc20-dev/spec-tmpl.k erc20-dev/rule-tmpl.k erc20-dev/hobby/spec-hobby.ini
	@echo >&2 "==  gen-spec: $@"
	mkdir -p $(dir $@)
	python3 scripts/gen-spec.py $^ hobby $(erc20_hobby_rules) > $@

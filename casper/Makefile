BUILD_DIR:=../.build

SPEC_GROUP:=casper
SPEC_INI:=casper-spec.ini

SPEC_NAMES:=recommended_source_epoch \
            recommended_target_hash-success \
            recommended_target_hash-failure-11 \
            recommended_target_hash-failure-12 \
            recommended_target_hash-failure-2 \
            deposit_exists-success-true \
            deposit_exists-success-false-1 \
            deposit_exists-success-false-2 \
            deposit_exists-failure \
            proc_reward \
            vote-1-2-3-4-5-6-success-1 \
            vote-1-failure-1 \
            vote-1-failure-2 \
            vote-1-2-failure-1 \
            vote-1-2-failure-2 \
            vote-1-2-3-failure-1 \
            vote-1-2-3-failure-2 \
            vote-1-2-3-4-failure-1 \
            vote-1-2-3-4-failure-2 \
            vote-1-2-3-4-5-failure-1 \
            vote-1-2-3-4-5-failure-2 \
            delete_validator-success \
            delete_validator-failure \
            main_hash_voted_frac-success-1 \
            main_hash_voted_frac-success-2 \
            main_hash_voted_frac-failure \
            total_curdyn_deposits_scaled-success \
            total_curdyn_deposits_scaled-failure-1 \
            total_curdyn_deposits_scaled-failure-21 \
            total_curdyn_deposits_scaled-failure-22 \
            total_prevdyn_deposits_scaled-success \
            total_prevdyn_deposits_scaled-failure-1 \
            total_prevdyn_deposits_scaled-failure-21 \
            total_prevdyn_deposits_scaled-failure-22 \
            deposit_size-success \
            deposit_size-failure-1 \
            deposit_size-failure-21 \
            deposit_size-failure-22 \
            increment_dynasty-is_finalized-justified \
            increment_dynasty-is_finalized-not-justified \
            increment_dynasty-not-is_finalized-justified \
            increment_dynasty-not-is_finalized-not-justified \
            logout-failure-1 \
            logout-failure-2 \
            logout-12-failure-3 \
            logout-12-failure-4 \
            logout-12-34-failure-5 \
            logout-12-34-5-success \
            esf-success \
            esf-failure \
            insta_finalize-success \
            insta_finalize-failure \
            collective_reward-success-normal-1 \
            collective_reward-success-normal-2 \
            collective_reward-success-zero-1-1 \
            collective_reward-success-zero-1-2 \
            collective_reward-success-zero-2 \
            collective_reward-failure

include ../resources/kprove.mak

# non-standard spec generation

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-3-4-5-6-success-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-3-4-5-6-success-1 recommended_target_hash-success proc_reward vote-1-2-3-4-5-6-success-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-failure-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-failure-1 recommended_target_hash-success vote-1-2-failure-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-failure-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-failure-2 recommended_target_hash-success vote-1-2-failure-2 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-3-failure-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-3-failure-1 recommended_target_hash-success vote-1-2-3-failure-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-3-failure-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-3-failure-2 recommended_target_hash-success vote-1-2-3-failure-2 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-3-4-failure-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-3-4-failure-1 recommended_target_hash-success vote-1-2-3-4-failure-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-3-4-failure-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-3-4-failure-2 recommended_target_hash-success vote-1-2-3-4-failure-2 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-3-4-5-failure-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-3-4-5-failure-1 recommended_target_hash-success vote-1-2-3-4-5-failure-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/vote-1-2-3-4-5-failure-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) vote-1-2-3-4-5-failure-2 recommended_target_hash-success vote-1-2-3-4-5-failure-2 > $@


$(SPECS_DIR)/$(SPEC_GROUP)/collective_reward-success-normal-1-spec.k: $(TMPLS) $(SPEC_INI)
	@echo >&2 "==  gen-spec: $@"
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) collective_reward-success-normal-1 esf-success deposit_exists-success-true collective_reward-success-normal-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/collective_reward-success-normal-2-spec.k: $(TMPLS) $(SPEC_INI)
	@echo >&2 "==  gen-spec: $@"
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) collective_reward-success-normal-2 esf-success deposit_exists-success-true collective_reward-success-normal-2 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/collective_reward-success-zero-1-1-spec.k: $(TMPLS) $(SPEC_INI)
	@echo >&2 "==  gen-spec: $@"
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) collective_reward-success-zero-1-1 esf-success deposit_exists-success-true deposit_exists-success-false-1 deposit_exists-success-false-2 collective_reward-success-zero-1-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/collective_reward-success-zero-1-2-spec.k: $(TMPLS) $(SPEC_INI)
	@echo >&2 "==  gen-spec: $@"
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) collective_reward-success-zero-1-2 esf-success deposit_exists-success-true deposit_exists-success-false-1 deposit_exists-success-false-2 collective_reward-success-zero-1-2 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/collective_reward-success-zero-2-spec.k: $(TMPLS) $(SPEC_INI)
	@echo >&2 "==  gen-spec: $@"
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) collective_reward-success-zero-2 esf-success deposit_exists-success-true deposit_exists-success-false-1 deposit_exists-success-false-2 collective_reward-success-zero-2 > $@


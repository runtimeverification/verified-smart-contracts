PROPERTIES_OUT_PREFIX=.out/properties.

PROPERTIES_ALL := $(wildcard $(PROPERTIES_DIR)/*.k)
PROPERTIES_PROOFS := $(wildcard $(PROPERTIES_DIR)/proof-*.k)
PROPERTIES_EXECUTION := $(filter-out $(PROPERTIES_PROOFS), $(PROPERTIES_ALL)) $(PROOF_EXECUTION) $(MAP_EXECUTION) $(INVARIANT_EXECUTION)

PROPERTIES_PROOF_TIMESTAMPS := $(addprefix $(PROPERTIES_OUT_PREFIX),$(notdir ${PROPERTIES_PROOFS:.k=.timestamp}))
PROPERTIES_PROOF_DEBUGGERS := $(addprefix $(PROPERTIES_OUT_PREFIX),$(notdir ${PROPERTIES_PROOFS:.k=.debugger}))

.PHONY: properties.clean ${PROPERTIES_PROOF_DEBUGGERS}

$(PROPERTIES_OUT_PREFIX)proof.timestamp: ${PROPERTIES_PROOF_TIMESTAMPS}
	$(DIR_GUARD)
	@touch $(PROPERTIES_OUT_PREFIX)proof.timestamp

$(PROPERTIES_OUT_PREFIX)proof-%.timestamp: ${PROPERTIES_DIR}/proof-%.k $(PROPERTIES_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Proving $*..."
	@cat /proc/uptime | sed 's/\s.*//' > $(PROPERTIES_OUT_PREFIX)proof-$*.duration.temp
	@((kprove $< --directory $(PROPERTIES_DIR) --haskell-backend-command $(BACKEND_COMMAND) > $(PROPERTIES_OUT_PREFIX)proof-$*.out 2>&1) && echo "$* done") || (cat $(PROPERTIES_OUT_PREFIX)proof-$*.out; echo "$* failed"; echo "$*" >> $(PROPERTIES_OUT_PREFIX)failures; false)
	@cat /proc/uptime | sed 's/\s.*//' >> $(PROPERTIES_OUT_PREFIX)proof-$*.duration.temp
	@$(SCRIPT_DIR)/compute-duration.py $(PROPERTIES_OUT_PREFIX)proof-$*.duration.temp > $(PROPERTIES_OUT_PREFIX)proof-$*.duration
	@rm $(PROPERTIES_OUT_PREFIX)proof-$*.duration.temp
	@touch $(PROPERTIES_OUT_PREFIX)proof-$*.timestamp

$(PROPERTIES_OUT_PREFIX)proof-%.debugger: ${PROPERTIES_DIR}/proof-%.k $(PROPERTIES_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Debugging $*..."
	@kprove $< --directory $(PROPERTIES_DIR) --haskell-backend-command $(DEBUG_COMMAND)

$(PROPERTIES_OUT_PREFIX)execution.timestamp: $(PROPERTIES_DIR)/properties-execute.k $(PROPERTIES_EXECUTION)
	$(DIR_GUARD)
	@echo "Compiling execution..."
	@kompile $(KOMPILE_FLAGS) $< --backend haskell --directory $(PROPERTIES_DIR)
	@touch $(PROPERTIES_OUT_PREFIX)execution.timestamp

properties.clean:
	-rm -r $(PROPERTIES_DIR)/*-kompiled
	-rm -r .kprove-*
	-rm kore-*.tar.gz
	-rm $(PROPERTIES_OUT_PREFIX)*

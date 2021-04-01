INVARIANT_OUT_PREFIX=out/invariant.

INVARIANT_ALL := $(wildcard $(INVARIANT_DIR)/*.k)
INVARIANT_PROOFS := $(wildcard $(INVARIANT_DIR)/proof-*.k)
INVARIANT_EXECUTION := $(filter-out $(INVARIANT_PROOFS), $(INVARIANT_ALL)) $(PROOF_EXECUTION) $(FUNCTIONS_EXECUTION)

INVARIANT_PROOF_TIMESTAMPS := $(addprefix $(INVARIANT_OUT_PREFIX),$(notdir ${INVARIANT_PROOFS:.k=.timestamp}))
INVARIANT_PROOF_DEBUGGERS := $(addprefix $(INVARIANT_OUT_PREFIX),${INVARIANT_PROOFS:.k=.debugger})

.PHONY: invariant.clean ${INVARIANT_PROOF_DEBUGGERS}

$(INVARIANT_OUT_PREFIX)proof.timestamp: ${INVARIANT_PROOF_TIMESTAMPS} $(INVARIANT_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@touch $(INVARIANT_OUT_PREFIX)proof.timestamp

$(INVARIANT_OUT_PREFIX)proof-%.timestamp: $(INVARIANT_DIR)/proof-%.k $(INVARIANT_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Proving $*..."
	@cat /proc/uptime | sed 's/\s.*//' > $(INVARIANT_OUT_PREFIX)proof-$*.duration.temp
	@((kprove $< --directory $(INVARIANT_DIR) --haskell-backend-command $(BACKEND_COMMAND) > $(INVARIANT_OUT_PREFIX)proof-$*.out 2>&1) && echo "$* done") || (cat $(INVARIANT_OUT_PREFIX)proof-$*.out; echo "$* failed"; echo "$*" >> $(INVARIANT_OUT_PREFIX)failures; false)
	@cat /proc/uptime | sed 's/\s.*//' >> $(INVARIANT_OUT_PREFIX)proof-$*.duration.temp
	@$(SCRIPT_DIR)/compute-duration.py $(INVARIANT_OUT_PREFIX)proof-$*.duration.temp > $(INVARIANT_OUT_PREFIX)proof-$*.duration
	@rm $(INVARIANT_OUT_PREFIX)proof-$*.duration.temp
	@touch $(INVARIANT_OUT_PREFIX)proof-$*.timestamp

$(INVARIANT_OUT_PREFIX)proof-%.debugger: $(INVARIANT_OUT_PREFIX)proof-%.k $(INVARIANT_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Debugging $*..."
	@kprove $< --directory $(INVARIANT_DIR) --haskell-backend-command $(DEBUG_COMMAND)

$(INVARIANT_OUT_PREFIX)execution.timestamp: $(INVARIANT_DIR)/invariant-execution.k ${INVARIANT_EXECUTION}
	$(DIR_GUARD)
	@echo "Compiling execution..."
	@kompile $< --backend haskell --directory $(INVARIANT_DIR)
	@touch $(INVARIANT_OUT_PREFIX)execution.timestamp

invariant.clean:
	-rm -r $(INVARIANT_DIR)/*-kompiled
	-rm -r .kprove-*
	-rm kore-*.tar.gz
	-rm $(INVARIANT_OUT_PREFIX)*
	-rm *.log

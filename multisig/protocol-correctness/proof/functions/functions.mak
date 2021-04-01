FUNCTIONS_OUT_PREFIX=out/functions.

include ${FUNCTIONS_DIR}/functions-dependency.mak

FUNCTIONS_PROOF_TIMESTAMPS := $(addprefix $(FUNCTIONS_OUT_PREFIX),$(notdir ${FUNCTIONS_PROOFS:.k=.timestamp}))
FUNCTIONS_PROOF_DEBUGGERS := $(addprefix $(FUNCTIONS_OUT_PREFIX),$(notdir ${FUNCTIONS_PROOFS:.k=.debugger}))

.PHONY: functions.clean ${FUNCTIONS_PROOF_DEBUGGERS}

$(FUNCTIONS_OUT_PREFIX)proof.timestamp: ${FUNCTIONS_PROOF_TIMESTAMPS}
	$(DIR_GUARD)
	@touch $(FUNCTIONS_OUT_PREFIX)proof.timestamp

$(FUNCTIONS_OUT_PREFIX)proof-%.timestamp: ${FUNCTIONS_DIR}/proof-%.k $(FUNCTIONS_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Proving $*..."
	@cat /proc/uptime | sed 's/\s.*//' > $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp
	@((kprove $< --directory $(FUNCTIONS_DIR) --haskell-backend-command $(BACKEND_COMMAND) > $(FUNCTIONS_OUT_PREFIX)proof-$*.out 2>&1) && echo "$* done") || (cat $(FUNCTIONS_OUT_PREFIX)proof-$*.out; echo "$* failed"; echo "$*" >> $(FUNCTIONS_OUT_PREFIX)failures; false)
	@cat /proc/uptime | sed 's/\s.*//' >> $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp
	@$(SCRIPT_DIR)/compute-duration.py $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp > $(FUNCTIONS_OUT_PREFIX)proof-$*.duration
	@rm $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp
	@touch $(FUNCTIONS_OUT_PREFIX)proof-$*.timestamp

$(FUNCTIONS_OUT_PREFIX)proof-%.debugger: ${FUNCTIONS_DIR}/proof-%.k $(FUNCTIONS_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Debugging $*..."
	@kprove $< --directory $(FUNCTIONS_DIR) --haskell-backend-command $(DEBUG_COMMAND)

$(FUNCTIONS_OUT_PREFIX)execution.timestamp: $(FUNCTIONS_DIR)/functions-execute.k $(FUNCTIONS_EXECUTION)
	$(DIR_GUARD)
	@echo "Compiling execution..."
	@kompile $< --backend haskell --directory $(FUNCTIONS_DIR)
	@touch $(FUNCTIONS_OUT_PREFIX)execution.timestamp

functions.clean:
	-rm -r $(FUNCTIONS_DIR)/*-kompiled
	-rm -r .kprove-*
	-rm kore-*.tar.gz
	-rm $(FUNCTIONS_OUT_PREFIX)*

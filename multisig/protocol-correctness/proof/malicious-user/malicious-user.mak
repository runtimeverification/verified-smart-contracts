MALICIOUS_USER_OUT_PREFIX=out/malicious-user.

MALICIOUS_USER_PROOFS := $(wildcard $(MALICIOUS_USER_DIR)/proofs/*.k)
MALICIOUS_USER_EXECUTION := $(wildcard $(MALICIOUS_USER_DIR)/*.k) $(PROOF_EXECUTION) $(INVARIANT_EXECUTION)

MALICIOUS_USER_PROOF_TIMESTAMPS := $(addprefix $(MALICIOUS_USER_OUT_PREFIX),$(notdir ${MALICIOUS_USER_PROOFS:.k=.timestamp}))
MALICIOUS_USER_PROOF_DEBUGGERS := $(addprefix $(MALICIOUS_USER_OUT_PREFIX),$(notdir ${MALICIOUS_USER_PROOFS:.k=.debugger}))

.PHONY: malicious-user.clean ${MALICIOUS_USER_PROOF_DEBUGGERS}

$(MALICIOUS_USER_OUT_PREFIX)proof.timestamp: ${MALICIOUS_USER_PROOF_TIMESTAMPS}
	$(DIR_GUARD)
	@touch $(MALICIOUS_USER_OUT_PREFIX)proof.timestamp

$(MALICIOUS_USER_OUT_PREFIX)proof-%.timestamp: ${MALICIOUS_USER_DIR}/proofs/proof-%.k $(MALICIOUS_USER_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Proving $*..."
	@cat /proc/uptime | sed 's/\s.*//' > $(MALICIOUS_USER_OUT_PREFIX)proof-$*.duration.temp
	@((kprove $< --directory $(MALICIOUS_USER_DIR) --haskell-backend-command $(BACKEND_COMMAND) > $(MALICIOUS_USER_OUT_PREFIX)proof-$*.out 2>&1) && echo "$* done") || (cat $(MALICIOUS_USER_OUT_PREFIX)proof-$*.out; echo "$* failed"; echo "$*" >> $(MALICIOUS_USER_OUT_PREFIX)failures; false)
	@cat /proc/uptime | sed 's/\s.*//' >> $(MALICIOUS_USER_OUT_PREFIX)proof-$*.duration.temp
	@$(SCRIPT_DIR)/compute-duration.py $(MALICIOUS_USER_OUT_PREFIX)proof-$*.duration.temp > $(MALICIOUS_USER_OUT_PREFIX)proof-$*.duration
	@rm $(MALICIOUS_USER_OUT_PREFIX)proof-$*.duration.temp
	@touch $(MALICIOUS_USER_OUT_PREFIX)proof-$*.timestamp

$(MALICIOUS_USER_OUT_PREFIX)proof-%.debugger: ${MALICIOUS_USER_DIR}/proofs/proof-%.k $(MALICIOUS_USER_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Debugging $*..."
	@kprove $< --directory $(MALICIOUS_USER_DIR) --haskell-backend-command $(DEBUG_COMMAND)

$(MALICIOUS_USER_OUT_PREFIX)execution.timestamp: $(MALICIOUS_USER_DIR)/malicious-user-execute.k $(MALICIOUS_USER_EXECUTION)
	$(DIR_GUARD)
	@echo "Compiling execution..."
	@kompile $< --backend haskell --directory $(MALICIOUS_USER_DIR)
	@touch $(MALICIOUS_USER_OUT_PREFIX)execution.timestamp

malicious-user.clean:
	-rm -r $(MALICIOUS_USER_DIR)/*-kompiled
	-rm -r .kprove-*
	-rm kore-*.tar.gz
	-rm $(MALICIOUS_USER_OUT_PREFIX)*

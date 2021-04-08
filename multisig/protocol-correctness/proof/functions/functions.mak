FUNCTIONS_OUT_PREFIX=.out/functions.

FUNCTIONS_TRUSTED_DIR=$(FUNCTIONS_DIR)

FUNCTIONS_DEPS_DIR=$(FUNCTIONS_DIR)/.deps

include ${FUNCTIONS_DIR}/functions-dependency.mak

FUNCTIONS_PROOF_TIMESTAMPS := $(addprefix $(FUNCTIONS_OUT_PREFIX),$(notdir ${FUNCTIONS_PROOFS:.k=.timestamp}))
FUNCTIONS_PROOF_DEBUGGERS := $(addprefix $(FUNCTIONS_OUT_PREFIX),$(notdir ${FUNCTIONS_PROOFS:.k=.debugger}))

FUNCTIONS_DEPFILES := $(addprefix $(FUNCTIONS_DEPS_DIR)/,$(notdir ${FUNCTIONS_PROOFS:.k=.deps}))
FUNCTIONS_TRUSTED_FILES := $(addprefix $(FUNCTIONS_TRUSTED_DIR)/,$(patsubst proof-%.k,trusted-%.k,$(notdir ${FUNCTIONS_PROOFS})))

.PHONY: functions.clean ${FUNCTIONS_PROOF_DEBUGGERS}
.SECONDARY:

# TODO: This is broken, I should add individual dependencies for each proof on their trusted imports.
$(FUNCTIONS_OUT_PREFIX)proof.timestamp: $(FUNCTIONS_OUT_PREFIX)trusted.timestamp ${FUNCTIONS_PROOF_TIMESTAMPS}
	$(DIR_GUARD)
	@touch $(FUNCTIONS_OUT_PREFIX)proof.timestamp

$(FUNCTIONS_OUT_PREFIX)trusted.timestamp: ${FUNCTIONS_TRUSTED_FILES}

$(FUNCTIONS_OUT_PREFIX)proof-%.timestamp: \
			${FUNCTIONS_DIR}/proof-%.k \
			${FUNCTIONS_DEPS_DIR}/proof-%.deps \
			$(FUNCTIONS_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Proving $*..."
	@cat /proc/uptime | sed 's/\s.*//' > $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp
	@((kprove $< --directory $(FUNCTIONS_DIR) --haskell-backend-command $(BACKEND_COMMAND) > $(FUNCTIONS_OUT_PREFIX)proof-$*.out 2>&1) && echo "$* done") || (cat $(FUNCTIONS_OUT_PREFIX)proof-$*.out; echo "$* failed"; echo "$*" >> $(FUNCTIONS_OUT_PREFIX)failures; false)
	@cat /proc/uptime | sed 's/\s.*//' >> $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp
	@$(SCRIPT_DIR)/compute-duration.py $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp > $(FUNCTIONS_OUT_PREFIX)proof-$*.duration
	@rm $(FUNCTIONS_OUT_PREFIX)proof-$*.duration.temp
	@touch $(FUNCTIONS_OUT_PREFIX)proof-$*.timestamp

${FUNCTIONS_DEPS_DIR}/proof-%.deps: ${FUNCTIONS_DIR}/proof-%.k
	$(DIR_GUARD)
	@echo "Generating dependencies for $*..."
	@kdep $< | sed 's#^.* : \\$$#$(FUNCTIONS_OUT_PREFIX)proof-$*.timestamp : \\#' > $@
	@kdep $< | sed 's#^.* : \\$$#$@ : \\#' >> $@

$(FUNCTIONS_TRUSTED_DIR)/trusted-%.k: ${FUNCTIONS_DIR}/proof-%.k $(SCRIPT_DIR)/make-trusted.py
	$(DIR_GUARD)
	@$(SCRIPT_DIR)/make-trusted.py $< $@

$(FUNCTIONS_OUT_PREFIX)proof-%.debugger: ${FUNCTIONS_DIR}/proof-%.k $(FUNCTIONS_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Debugging $*..."
	@kprove $< --directory $(FUNCTIONS_DIR) --haskell-backend-command $(DEBUG_COMMAND)

$(FUNCTIONS_OUT_PREFIX)execution.timestamp: $(FUNCTIONS_DIR)/functions-execute.k $(FUNCTIONS_EXECUTION)
	$(DIR_GUARD)
	@echo "Compiling execution..."
	@kompile $(KOMPILE_FLAGS) $< --backend haskell --directory $(FUNCTIONS_DIR)
	@touch $(FUNCTIONS_OUT_PREFIX)kompile.timestamp

functions.clean:
	-rm -r $(FUNCTIONS_DIR)/*-kompiled
	-rm -r .kprove-*
	-rm kore-*.tar.gz
	-rm $(FUNCTIONS_OUT_PREFIX)*
	# TODO: Delete only function dependencies
	-rm -r ${FUNCTIONS_DEPS_DIR}

-include $(FUNCTIONS_DEPFILES)
-include $(FUNCTIONS_TRUSTED_DEPFILES)

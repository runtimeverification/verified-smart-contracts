MAP_OUT_PREFIX=.out/map.

MAP_ALL := $(wildcard $(MAP_DIR)/*.k)
MAP_PROOFS := $(wildcard $(MAP_DIR)/proof-*.k)
MAP_EXECUTION := $(filter-out $(MAP_PROOFS), $(MAP_ALL))

MAP_PROOF_TIMESTAMPS := $(addprefix $(MAP_OUT_PREFIX),$(notdir ${MAP_PROOFS:.k=.timestamp}))
MAP_PROOF_DEBUGGERS := $(addprefix $(MAP_OUT_PREFIX),$(notdir ${MAP_PROOFS:.k=.debugger}))

.PHONY: map.clean ${MAP_PROOF_DEBUGGERS}

$(MAP_OUT_PREFIX)proof.timestamp: ${MAP_PROOF_TIMESTAMPS}
	$(DIR_GUARD)
	@touch $(MAP_OUT_PREFIX)proof.timestamp

$(MAP_OUT_PREFIX)proof-%.timestamp: ${MAP_DIR}/proof-%.k $(MAP_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Proving $*..."
	@cat /proc/uptime | sed 's/\s.*//' > $(MAP_OUT_PREFIX)proof-$*.duration.temp
	@((kprove $< --directory $(MAP_DIR) --haskell-backend-command $(BACKEND_COMMAND) > $(MAP_OUT_PREFIX)proof-$*.out 2>&1) && echo "$* done") || (cat $(MAP_OUT_PREFIX)proof-$*.out; echo "$* failed"; echo "$*" >> $(MAP_OUT_PREFIX)failures; false)
	@cat /proc/uptime | sed 's/\s.*//' >> $(MAP_OUT_PREFIX)proof-$*.duration.temp
	@$(SCRIPT_DIR)/compute-duration.py $(MAP_OUT_PREFIX)proof-$*.duration.temp > $(MAP_OUT_PREFIX)proof-$*.duration
	@rm $(MAP_OUT_PREFIX)proof-$*.duration.temp
	@touch $(MAP_OUT_PREFIX)proof-$*.timestamp

$(MAP_OUT_PREFIX)proof-%.debugger: ${MAP_DIR}/proof-%.k $(MAP_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@echo "Debugging $*..."
	@kprove $< --directory $(MAP_DIR) --haskell-backend-command $(DEBUG_COMMAND)

$(MAP_OUT_PREFIX)execution.timestamp: $(MAP_DIR)/map-execute.k $(MAP_EXECUTION)
	$(DIR_GUARD)
	@echo "Compiling execution..."
	@kompile $< --backend haskell --directory $(MAP_DIR)
	@touch $(MAP_OUT_PREFIX)execution.timestamp

map.clean:
	-rm -r $(MAP_DIR)/*-kompiled
	-rm -r .kprove-*
	-rm kore-*.tar.gz
	-rm $(MAP_OUT_PREFIX)*

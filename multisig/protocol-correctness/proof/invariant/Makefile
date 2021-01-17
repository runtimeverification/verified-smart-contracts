include ../settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR = ..

PROOF_DIR = ..
include ../proof-dependency.mak

INVARIANT_DIR = .
include invariant.mak

INVARIANT_PERFORM = $(wildcard $(INVARIANT_DIR)/proof-perform-*.k)
FINVARIANT_PERFORM = $(filter-out $(INVARIANT_DIR)/proof-perform-action-endpoint.k, $(INVARIANT_PERFORM))
INVARIANT_PERFORM_TIMESTAMPS = $(addprefix $(INVARIANT_OUT_PREFIX),$(notdir ${FINVARIANT_PERFORM:.k=.timestamp}))

.PHONY: all clean execution short perform

all: $(INVARIANT_OUT_PREFIX)proof.timestamp

execution: $(INVARIANT_OUT_PREFIX)execution.timestamp

short: $(INVARIANT_OUT_PREFIX)short-proofs.timestamp

perform: $(INVARIANT_OUT_PREFIX)proofperform.timestamp

$(INVARIANT_OUT_PREFIX)short-proofs.timestamp: $(INVARIANT_OUT_PREFIX)proof-init-loop.timestamp $(INVARIANT_OUT_PREFIX)proof-count-can-sign.timestamp $(INVARIANT_OUT_PREFIX)proof-init.timestamp $(INVARIANT_OUT_PREFIX)proof-listlen.timestamp $(INVARIANT_OUT_PREFIX)proof-perform-add-proposer-1.timestamp  $(INVARIANT_OUT_PREFIX)proof-perform-add-proposer-2.timestamp  $(INVARIANT_OUT_PREFIX)proof-perform-add-proposer-3.timestamp  $(INVARIANT_OUT_PREFIX)proof-perform-change-quorum.timestamp $(INVARIANT_OUT_PREFIX)proof-perform-nothing.timestamp $(INVARIANT_OUT_PREFIX)proof-perform-remove-user-1.timestamp  $(INVARIANT_OUT_PREFIX)proof-perform-remove-user-2.timestamp $(INVARIANT_OUT_PREFIX)proof-perform-remove-user-5.timestamp $(INVARIANT_OUT_PREFIX)proof-perform-s-c-call.timestamp $(INVARIANT_OUT_PREFIX)proof-perform-s-c-deploy.timestamp $(INVARIANT_OUT_PREFIX)proof-perform-send-egld.timestamp $(INVARIANT_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@touch $(INVARIANT_OUT_PREFIX)short-proof.timestamp

$(INVARIANT_OUT_PREFIX)proofperform.timestamp: ${INVARIANT_PERFORM_TIMESTAMPS} $(INVARIANT_OUT_PREFIX)execution.timestamp
	$(DIR_GUARD)
	@touch $(INVARIANT_OUT_PREFIX)proofperform.timestamp

clean: invariant.clean

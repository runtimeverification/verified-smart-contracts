SEMANTICS_DIR = $(PROOF_DIR)/..

SEMANTICS_K := $(wildcard $(SEMANTICS_DIR)/*.k)

PROOF_ALL := $(wildcard $(PROOF_DIR)/*.k)
PROOF_PROOFS := $(wildcard $(PROOF_DIR)/proof-*.k)
PROOF_EXECUTION := $(filter-out $(PROOF_PROOFS), $(PROOF_ALL)) $(SEMANTICS_K)

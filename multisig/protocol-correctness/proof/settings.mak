SHELL?=/bin/bash -euo pipefail

KOMPILE_FLAGS=-I $(shell git rev-parse --show-toplevel)/multisig

BACKEND_COMMAND ?= "kore-exec --smt-timeout 4000"
DEBUG_COMMAND ?= "kore-repl --smt-timeout 4000 --repl-script /home/virgil/runtime-verification/k/haskell-backend/src/main/native/haskell-backend/kore/data/kast.kscript"
DIR_GUARD ?= @mkdir -p $(@D)

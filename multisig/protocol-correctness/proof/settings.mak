SHELL?=/bin/bash -euo pipefail

BACKEND_COMMAND ?= "kore-exec --smt-timeout 200"
DEBUG_COMMAND ?= "kore-repl --smt-timeout 200 --repl-script /home/virgil/runtime-verification/k/haskell-backend/src/main/native/haskell-backend/kore/data/kast.kscript"
DIR_GUARD ?= @mkdir -p $(@D)

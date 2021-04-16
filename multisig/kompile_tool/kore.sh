#!/usr/bin/env bash

set -e

KOMPILE_DIR=`dirname $1`
shift

DEFINITION=$(realpath $1)
shift

SPEC=$(realpath $1)
shift

COMMAND=$1
shift

OUTPUT=$(realpath $1)
shift

MODULE_NAME=$(cat $COMMAND | sed 's/^.*--module \([^ ]*\) .*$/\1/')

SPEC_MODULE_NAME=$(cat $COMMAND | sed 's/^.*--spec-module \([^ ]*\) .*$/\1/')

KOMPILE_TOOL_DIR=kompile_tool

KORE_EXEC=$(realpath $KOMPILE_TOOL_DIR/k/bin/kore-exec)
KORE_REPL=$(realpath $KOMPILE_TOOL_DIR/k/bin/kore-repl)

REPL_SCRIPT=$(realpath $KOMPILE_TOOL_DIR/kast.kscript)

BACKEND_COMMAND=$KORE_EXEC
if [ $# -eq 0 ]; then
  BACKEND_COMMAND=$KORE_EXEC
else
  if [ "$1" == "--debug" ]; then
    BACKEND_COMMAND="$KORE_REPL --repl-script $REPL_SCRIPT"
  else
    echo "Unknown argument: '$1'"
    exit 1
  fi
fi

PATH=$(realpath $KOMPILE_TOOL_DIR/k/bin):$PATH

cd $(dirname $KOMPILE_DIR)

$BACKEND_COMMAND \
    --smt-timeout 4000 \
    $DEFINITION \
    --prove $SPEC \
    --module $MODULE_NAME \
    --spec-module $SPEC_MODULE_NAME \
    --output $OUTPUT

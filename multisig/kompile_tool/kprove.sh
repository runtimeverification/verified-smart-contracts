#!/usr/bin/env bash

set -e

PARENT_DIR=$(dirname $0)

KOMPILE_DIR=$(dirname $1)
shift

TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT

ORIGINAL_FILE=$1
shift

PROOF_FILE=$(realpath $1)
shift

BREADTH=$1
shift

#KOMPILE_PARENT = $(dirname $KOMPILE_DIR)
#
MODULE_NAME=$(basename "$ORIGINAL_FILE" | sed 's/\.[^\.]*$//' | tr [:lower:] [:upper:])

cp -rL $KOMPILE_DIR $TMP_DIR
chmod -R a+w $TMP_DIR/*

KOMPILE_TOOL_DIR=kompile_tool

KPROVE=$(realpath $KOMPILE_TOOL_DIR/k/bin/kprove)
REPL_SCRIPT=$(realpath $KOMPILE_TOOL_DIR/kast.kscript)

#PROOF_FILE_PATH=$(realpath $PROOF_FILE)
#REPL_SCRIPT_PATH=$(realpath $REPL_SCRIPT)
#
KORE_EXEC="kore-exec --breadth $BREADTH"
KORE_REPL="kore-repl --repl-script $REPL_SCRIPT"

BACKEND_COMMAND=$KORE_EXEC
if [ $# -eq 0 ]; then
  BACKEND_COMMAND=$KORE_EXEC
else
  if [ "$1" == "--debug" ]; then
    BACKEND_COMMAND=$KORE_REPL
  else
    echo "Unknown argument: '$1'"
    exit 1
  fi
fi

cd $TMP_DIR
echo $TMP_DIR

$KPROVE \
  --haskell-backend-command "$BACKEND_COMMAND --smt-timeout 4000" \
  --spec-module "$MODULE_NAME" \
  "$PROOF_FILE"

#  --directory "$TMP_DIR" \

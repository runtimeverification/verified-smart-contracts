#!/usr/bin/env bash

set -e -x

echo "$@"

PARENT_DIR=`dirname $0`

KOMPILE_DIR=`dirname $1`
shift

TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT

ORIGINAL_FILE=$1
shift

PROOF_FILE=$1
shift

MODULE_NAME=$(basename "$ORIGINAL_FILE" | sed 's/\.[^\.]*$//' | tr [:lower:] [:upper:])

cp -rL $KOMPILE_DIR $TMP_DIR
chmod -R a+w $TMP_DIR/*
ls -a $TMP_DIR

KOMPILE_TOOL_DIR=kompile_tool

KPROVE=$KOMPILE_TOOL_DIR/k/bin/kprove
REPL_SCRIPT=$KOMPILE_TOOL_DIR/kast.kscript

BACKEND_COMMAND="kore-exec"
if [ $# -eq 0 ]; then
  BACKEND_COMMAND="kore-exec"
else
  if [ "$1" == "--debug" ]; then
    BACKEND_COMMAND="kore-repl --repl-script $REPL_SCRIPT"
  else
    echo "Unknown argument: '$1'"
    exit 1
  fi
fi

$KPROVE \
  --haskell-backend-command "$BACKEND_COMMAND --smt-timeout 4000" \
  --directory "$TMP_DIR" \
  --spec-module "$MODULE_NAME" \
  "$PROOF_FILE"
# -I `pwd`

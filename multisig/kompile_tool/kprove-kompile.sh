#!/usr/bin/env bash

set -e

KOMPILE_DIR=`dirname $1`
shift

ORIGINAL_FILE=$1
shift

PROOF_FILE=$(realpath $1)
shift

SPEC_OUTPUT=$1
shift

DEFINITION_OUTPUT=$1
shift

COMMAND_OUTPUT=$1
shift

MODULE_NAME=$(basename "$ORIGINAL_FILE" | sed 's/\.[^\.]*$//' | tr [:lower:] [:upper:])

KOMPILE_TOOL_DIR=kompile_tool

KPROVE=$(realpath $KOMPILE_TOOL_DIR/k/bin/kprove)

TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT

cp -rL $KOMPILE_DIR $TMP_DIR
chmod -R a+w $TMP_DIR/*

pushd $TMP_DIR

$KPROVE \
  --spec-module "$MODULE_NAME" \
  --dry-run \
  "$PROOF_FILE" > output

SPEC_FILE=$(cat output | grep kore-exec | sed 's/^.*--prove \([^ ]*\) .*$/\1/')
COMMAND=$(cat output | grep kore-exec)

popd

cp $SPEC_FILE $SPEC_OUTPUT

DEFINITION_FILE=$(dirname $SPEC_FILE)/vdefinition.kore

cp $DEFINITION_FILE $DEFINITION_OUTPUT

echo $COMMAND > $COMMAND_OUTPUT

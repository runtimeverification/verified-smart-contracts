#!/usr/bin/env bash

set -e

PARENT_DIR=`dirname $0`
OUTPUT=$1
shift

KOMPILE_DIR=`dirname $1`
shift

TMP_DIR=$1
shift

cp -rL $KOMPILE_DIR $TMP_DIR
chmod -R a+w $TMP_DIR/*

KPROVE=$PARENT_DIR/kprove_tool.runfiles/__main__/kompile_tool/k/bin/kprove
$KPROVE --haskell-backend-command "kore-exec --smt-timeout 4000" --directory "$TMP_DIR" "$@"
# -I `pwd`
touch $OUTPUT

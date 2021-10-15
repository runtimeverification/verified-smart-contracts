#!/usr/bin/env bash

set -e

PARENT_DIR=`dirname $0`

OUTPUT_DIR=`dirname $1`
OUTPUT_DIR=`dirname $OUTPUT_DIR`
shift

KOMPILE=$PARENT_DIR/kompile_tool.runfiles/__main__/kompile_tool/k/bin/kompile
$KOMPILE --backend haskell -I `pwd` --directory $OUTPUT_DIR "$@"

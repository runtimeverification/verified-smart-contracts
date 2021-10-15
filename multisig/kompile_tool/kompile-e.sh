#!/usr/bin/env bash

set -e

PARENT_DIR=`dirname $0`

KOMPILE=$PARENT_DIR/kompile_e_tool.runfiles/__main__/kompile_tool/k/bin/kompile
$KOMPILE --backend haskell -I `pwd` -E "$@" > /dev/null

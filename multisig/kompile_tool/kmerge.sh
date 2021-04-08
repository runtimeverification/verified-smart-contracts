#!/usr/bin/env bash

set -e

OUTPUT=$1
shift

cat "$@" | sed 's/^.*\/\/@ Bazel remove\s*$/\/\/ Removed by Bazel + kmerge./' > $OUTPUT

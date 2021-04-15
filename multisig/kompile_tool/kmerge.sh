#!/usr/bin/env bash

set -e

OUTPUT=$1
shift

FIRST=$1
shift

cat $FIRST | sed 's/^.*\/\/@ Bazel remove\s*$/\/\/ Removed by Bazel + kmerge./' > $OUTPUT
echo >> $OUTPUT

for f in "$@"
do
  cat "$f" | sed 's/^.*\/\/@ Bazel remove\s*$/\/\/ Removed by Bazel + kmerge./' >> $OUTPUT
  echo >> $OUTPUT
done

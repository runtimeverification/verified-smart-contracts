#!/usr/bin/env bash

# Workaround a Bazel bug, kompile should be available in runfiles.
KOMPILE=`find . -name kompile | head -n 1`
$KOMPILE "$@"
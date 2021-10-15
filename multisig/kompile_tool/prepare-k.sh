#!/usr/bin/env bash

KOMPILE=`which kompile`
BIN=`dirname $KOMPILE`
RELEASE=`dirname $BIN`

mkdir k

cp -r $RELEASE/* k

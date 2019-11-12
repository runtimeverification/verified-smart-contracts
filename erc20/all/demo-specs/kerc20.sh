#!/bin/bash
token=${1%.ini}
export NPROCS=10
make $(realpath `pwd`/../../../specs/erc20/all/demo-specs/$token/erc20-spec.ini.test) >/dev/null 2>&1
cat ../../../specs/erc20/all/demo-specs/$token/*.out | grep '^SPEC' | cut -f 1-3 -d ' ' | cut -f 1,11 -d '/'

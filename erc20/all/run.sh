#!/bin/bash

NPROCS=2

  [[ $# -eq 1 ]] || { echo "Illegal number of parameters"; exit; }
  rm -f .make-internal/erc20-spec.ini
  cat fragments/root.ini \
    fragments/totalSupply.ini \
    fragments/balanceOf.ini \
    fragments/allowance.ini \
    fragments/approve.ini \
    fragments/transfer.ini \
    fragments/transferFrom.ini \
    $1 >.make-internal/erc20-spec.ini
  make -C .make-internal clean all
  make -C .make-internal -i -j "NPROCS" test

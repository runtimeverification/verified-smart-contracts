  [[ $# -eq 1 ]] || { echo "Illegal number of parameters"; exit; }
  rm -f erc20-spec.ini
  cat root.ini \
    totalSupply.ini \
    balanceOf.ini \
    allowance.ini \
    approve.ini \
    transfer.ini \
    transferFrom.ini \
    $1 >erc20-spec.ini
  make clean
  make
  make -i -j "$(nproc)" test

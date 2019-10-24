#!/usr/bin/env python3

# Prerequisites: pip install pyetherchain
#
# usage: python3 get-bytecode.py <address>

import sys
from pyetherchain.pyetherchain import EtherChain


def main():
    address = sys.argv[1]
    print(EtherChain().account(address).code)


if __name__ == '__main__':
    main()

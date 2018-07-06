#!/usr/bin/env python3.6
import re
import sys
import json
import types
import os

from typing import List


def main(debuggDir):
    debugg_lines = [line.rstrip('\n') for line in open(debuggDir + "/debugg.log", "r")]
    branch_logged = False
    for line in debugg_lines:
        if " node " in line:
            process_node(line)
            branch_logged = False
        elif " branch " in line and not branch_logged:
            print("\nBranching!\n======================================================\n")
            branch_logged = True


# 93384 node 12_1_487122957_80037969 12_1_487122957_80037969
# time "node" step_pathId_term_constraint <same>
rstep_pattern = re.compile("(\d+) node (\d+)_(\d+)_(\d+)_(\d+)")


def process_node(line):
    (time, step, pathId, termId, constrId) = rstep_pattern.match(line).groups()
    with open("{}/nodes/{}.json".format(debuggDir, termId), "r") as f:
        term = json.load(f)
    with open("{}/nodes/{}.json".format(debuggDir, constrId), "r") as f:
        constraint = json.load(f)

    print("\nSTEP {} path {} in {} ms\n======================================================\n"
          .format(step, pathId, time))
    printTerm(term["term"], None)

    print("/\\")
    printTerm(constraint["term"], None)


def printTerm(term, label, end='\n'):
    nodeType = term["node"]
    if nodeType == "KApply":
        if term["label"] == "#And":
            printTerm(term["args"][0], None, end="")
            print(" #And")
            printTerm(term["args"][1], None)
        else:
            cells = term["args"]
            for cell in cells:
                printTerm(cell, term["label"])
    else:
        cellOut = term["token"] if nodeType == "KToken" \
            else term["name"] if nodeType == "KVariable" \
            else term["name"] if nodeType == "KVariable" \
            else term
        print((label + ": " if label is not None else "") + cellOut, end=end)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("One argument expected: debugg dir")
        sys.exit(1)
    debuggDir = sys.argv[1]
    main(debuggDir)

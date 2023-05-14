#!/usr/bin/env python3

import re
import sys

# Output a plan in the format that can be read by the validator.
# Input:
#   plan - the list of actions in the sas_plan file.

def print_solution(plan):
    for action in plan:
        s = re.sub(r"\(|\)", "", action).upper()
        if s[0] == ';':
            continue
        terms = s.split(" ")
        if terms[0] == 'DRAW':
            print(f'DRAW') # if DRAW, no arguments are passed
        elif terms[0] == 'MATCH':
            print(f'MATCH {terms[1]} {terms[2]}') # indices 1 and 2 show the matched elements
        elif terms[0] == 'REMOVE-KING':
            print(f'MATCH {terms[1]}') # the only index is the king
        elif terms[0] == 'SHUFFLE':
            print('DRAW') # in case of a new cycle, put DRAW


def print_usage():
    print("Usage:")
    print()
    print("      ", sys.argv[0], "sas_plan")
    print()

def main():
    if len(sys.argv) != 2:
        print_usage()
        exit(1)

    infile_name = sys.argv[1]

    plan = []
    with open(infile_name) as infile:
        for line in infile:
            s = line.strip()
            if s == '': continue
            plan.append(s)

    print_solution(plan)

if __name__ == "__main__":
    main()

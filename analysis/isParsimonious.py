"""
Let's say we have a tree with 3 species: A, B, C.
A and B are the ingroup.
C is the outgroup.

Let's say the sequence identity between A and C is idt_AC.
Let's say the sequence identity between A and B is idt_AB.
Let's say the sequence identity between B and C is idt_BC.

Then the sequence mismatch rate between A and C is 1 - idt_AC = x.
Then the sequence mismatch rate between A and B is 1 - idt_AB = y.
Then the sequence mismatch rate between B and C is 1 - idt_BC = z.

Let's say the probablity of mutating from the common ancestor of A and B and C to A is p_A.
Let's say the probablity of mutating from the common ancestor of A and B and C to B is p_B.
Let's say the probablity of mutating from the common ancestor of A and B and C to C is p_C.

We can assume:
x = p_A + p_C
y = p_B + p_C
z = p_A + p_B

The probability of Parsimony p_pars = (substitution occurred only once) is p_A/3 * (1-p_B) * (1-p_C)
The probability of non-Parsimony p_nonpars = (substitution occurred twice) is (1-p_A) * p_B/3 * p_C/3

Thus the ratio of two senarios is
p_pars / p_nonpars = (p_A/3 * (1-p_B) * (1-p_C)) / ((1-p_A) * p_B/3 * p_C/3)
                                   = (1-p_C) / p_C * 3

Input:
        - idt_AB
        - idt_ABC (We assume idt_ABC = idt_AC = idt_BC)

Output:
        - isParsimonious (1-p_C)/p_C*3
"""

import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--idt_ingroup", type=float, required=True)
    parser.add_argument("--idt_outgroup", type=float, required=True)
    args = parser.parse_args()

    idt_ingroup = args.idt_ingroup
    idt_outgroup = args.idt_outgroup
    p_A = (100 - idt_ingroup) / 2
    p_B = (100 - idt_ingroup) / 2
    p_C = 100 - idt_outgroup - p_A
    print(f"p_A = {p_A}, p_B = {p_B}, p_C = {p_C}")
    print(f"p_pars / p_nonpars = (100-p_C) / p_C * 3 = {((100-p_C) / p_C) * 3}")

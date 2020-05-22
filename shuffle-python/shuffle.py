#! /usr/bin/env python
# -*- coding: utf-8 -*-
# Time-stamp: <2019-06-07 14:50:07 christophe@pallier.org>

"""
Shuffles lines from a table with optional constraints on repetitions.

Constraints are expressed as maximum number of repetitions of string
in given columns, or minimal distance (in rows) between the repetition
of a string
"""

import csv
import random
import time

DEBUG = False

##
def get_table_from_csv_file(csvfilename):
    csvfile = open(csvfilename)
    dialect = csv.Sniffer().sniff(csvfile.readline(),
                                  [',', ';', '\t', ' '])
    assert(dialect is not None)
    csvfile.seek(0)
    data = csv.reader(csvfile, dialect)
    return [row for row in data]  # maybe we should use row.decode.utf('utf-8')


##
def shuffle_0(l):
    """
    returns a new list containing the elements of l shuffled in random order
    """
    l2 = l[:]
    random.shuffle(l2)
    return l2


##
def shuffle_equiprob(table, maxrep=None, mingap=None, time_limit=1):
    """
    table: list of lists of strings (each row is a list of strings)
    maxrep: maximum number of repetitions of a string in a columns
    mingap: minimum distances (in rows) between two repetitions of a string
    in the same column
    (maxrep and mingat are dictionaries mapping column number
    to a number expressing the constraint)
    """
    start_time = time.time()
    go_on = True
    while go_on and (time.time() < (start_time + time_limit)):
        random.shuffle(table)
        ok, _ = check_constraints(table, maxrep, mingap)
        go_on = not(ok)
    if not(ok):
        return None
    else:
        return table


##
##
def check_constraints(table, maxrep=None, mingap=None, irow=0):
    """Checks if a permutation respects constraints.


    Args:
        table (list of list of strings): table whose row must be permuted
        maxrep (dict): maximum number of repetitions of a string
        mingap (dict): minimum gap between two repetitions of a string

    Returns:
        a pair consisting of True or False indicating if the table
        respects the contraints, and a row number pointing to the first row
        violating the constraints.


    Note: These variables should be dictionaries
    mapping column number to a number., for example maxrep={3:4, 5:2} means
    that columns 3 and 5 (starting from 0 as per Python convention) should have
    maximum of repetitions of the same label 4 and 2 times respectively)


    """

    if maxrep is not None:
        repetitions = maxrep.copy()
        for f in list(repetitions.keys()): repetitions[f] = 1

    if irow < 0: irow = 0
    if (DEBUG): print("checking contraints; irow=%d, row=%s" % (irow, table[irow]))

    previous = table[irow]
    irow += 1
    ok = True
    while ok and irow < len(table):
        row = table[irow]
        if (DEBUG): print("irow=%d, row=%s, previous=%s" % (irow, row, previous))

        if maxrep is not None:
        # check maxrep constraints
            for field in list(maxrep.keys()):
                if previous[field] == row[field]:
                    repetitions[field] += 1
                    ok = repetitions[field] <= maxrep[field]
                else:
                    repetitions[field] = 1
                if not(ok):
                    if (DEBUG): print("Violation of maxrep %d %d" % (field, maxrep[field]))
                    break

        if mingap is not None:
        # check mingap constraints
            for field in list(mingap.keys()):
                back = irow - mingap[field]
                if back < 0: back = 0
                while ok and (back < irow):
                    ok = ok and (table[back][field] != table[irow][field])
                    back += 1
                if not(ok):
                    if (DEBUG): print("Violation of mingap %d:%d" % (field, mingap[field]))
                    break

        previous = row
        if ok:
            irow += 1

    if (DEBUG): print("Exiting check_constraints ok=%d, irow=%d" % (ok, irow))
    return (ok, irow)


def shuffle_build(table, maxrep=None, mingap=None, maxtime=1):
    n = len(table)
    assert(mingap is not None or maxrep is not None)
    m1 , m2 = 0, 0
    if mingap is not None:
        m1 = max(mingap.values())
    if maxrep is not None:
        m2 = max(maxrep.values())
    backtrack = max(m1, m2)

    start_time = time.time()
    random.shuffle(table)
    ok = False
    irow = 0
    nfailure = 0
    while not(ok) and (time.time() < (start_time + maxtime)):
        ok, irow = check_constraints(table, maxrep, mingap,
                                     irow - backtrack)
        if not(ok):
            nfailure += 1
            if (irow >= (n - 1)) or (nfailure > (n * 100)):  # start again
                if (DEBUG): print("Let's start again")
                random.shuffle(table)
                if (DEBUG): print(table)
                irow = 0
                nfailure = 0
            else:  # swap current row with another one further down the table
                if (DEBUG): print("swap current row #%d " % irow, end=' ')
                i2 = random.choice(list(range(irow + 1, n)))
                if (DEBUG): print("... with row #%d" % i2)
                tmp = table[irow]
                table[irow] = table[i2]
                table[i2] = tmp

    if ok:
        return table
    else:
        return None


##
def test():
    t = ['a'] * 9 + ['b'] * 10
    print(shuffle_equiprob(t, mingap={0: 2}))
    print("----------")
    print(shuffle_build(t, maxrep={0: 1}))

##
if __name__ == '__main__':
    ## example: we shuffle test0.csv
    t = get_table_from_csv_file('test0.csv')
    for i in range(10):
        t2 = shuffle_build(t, mingap={2: 2})
        ofile = open("list%02d.csv" % (i + 1), 'wt')
        writer = csv.writer(ofile, dialect='excel')
        for row in t2:
            writer.writerow(row)
        ofile.close()

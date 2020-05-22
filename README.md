shuffle
=======

Randomly permutes the lines of a file, with optional constraints.

Shuffle reads lines and outputs them (or a subset of them) in a random
order, possibly with constraints on successive lines.  If no contraint
is specified, all permutations are equiprobable. Otherwise,
constraints can be specified as maximum numbers of repetitions of
labels in one or several columns of the output, or on the minimum
distance between successive repetitions.

There are three implementations, in AWK, Perl and Python.

Christophe@Pallier.org

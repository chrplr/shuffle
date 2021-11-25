Shuffle:a program to randomize lists with optional sequential constraints 
=========================================================================

**shuffle** produces “randomized” or “quasi-randomized” sequences. 

It allows to select permutations that avoid repetitions of similar items: The user can set limits on the number of consecutive occurrences of items associated with some labels, or, can specify the minimal distance separating two items with the same labels. This is useful to extract random samples from a dictionary, or to generate quasi-randomized lists of stimuli that avoid runs of trials belonging to the same categories (see [shuffle.pdf](shuffle.pdf) for more details).

In practice, shuffle reads text lines and then outputs them (or a subset of them) in a random
order, possibly with constraints on successive lines.  If no contraint
is specified, all permutations are equiprobable. Otherwise,
constraints can be specified as maximum numbers of repetitions of
labels in one or several columns of the output, or on the minimum
distance between successive repetitions.

There are three implementations, in AWK, Perl and Python.

See [shuffle-awk/README.md](shuffle-awk/README.md) for examples of usage.

Christophe@Pallier.org

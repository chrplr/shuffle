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

Here are some examples of command lines with the [AWK implementation](shuffle-awk/README.md), 

    shuffle -?               # to display a short help
    shuffle sample.txt
    shuffle n=10 sample.txt  # limits output to 10 lines
    shuffle n=10 sample.txt  # new permutation of 10 lines
    shuffle n=5 seed=134 sample.txt # sets the seed of the random generator
    shuffle n=5 seed=134 sample.txt # you get the same permutation as before...
    shuffle n=8 constr='2' sample.txt # no more than 2 succesive lines with
                                      # the same value in column 1
    shuffle n=8 constr='0 3' sample.txt # no more than 3 succesive lines with
                                        # the same value in column 2
    shuffle n=8 constr='2 2' sample.txt # no more than 2 succesive lines with
                                        # the same values in column 1 or column 2
    shuffle n=8 constr='1 1' sample.txt # not repetition of colum 1 and 2 on successive lines


Christophe@Pallier.org

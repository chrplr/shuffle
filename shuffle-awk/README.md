Shuffle reads the lines from the standard input or from a file given
as argument, and outputs them (or a subset of them) in a random order,
with possible restrictions.

If no contraint is specified on the command line, all permutations are
equiprobable. Otherwise, constraints can be specified as maximum
number of repetitions of labels in one or several columns of the
output. All the permutations fullfilling the constraints are
equiprobable.


INSTALL
=======

shuffle requires gawk to be installed on your system (gawk, the GNU
version of the awk programming language, can be found at
http://www.gnu.org). We assume in the following that gawk is
installed, and available in one of the directories of the PATH.

If you use a un*x shell, you can just copy 'shuffle' in a one of the
directories of your path (e.g. /usr/local/bin or ~/bin), and
'man/shuffle.1' in one of the directories accessed by man
(e.g. /usr/local/man/man1 or ~/man), and you are set.

If you use a DOS/Windows system:
1. copy "gawk.exe" and "shuffle" in the directory "c:\awk"
2. add the following line (with edit or notepad) in the file "c:\autoexec.bat":
	doskey shuffle=c:\awk\gawk.exe -f c:\awk\shuffle $*
3. reboot your system. 
4. At the DOS prompt, check that you can now type 'shuffle -?'
The manual is accesible both in txt and in ps (postscript) format in the man
directory.


TESTING SHUFFLE
===============
 
To test 'shuffle' and understand its functioning, we suggest you try:

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
shuffle n=8 constr='1 1' sample.txt # not much randomness with strict constr

Now, you will probably want to save the output of shuffle in a file. 
To do that, use the redirection operator '>':
Supposing that you want to shuffle the file 'mylist.txt' and put the result
in, say, 'newlist.txt', you would type:

shuffle mylist.txt >newlist.txt


CONCLUSION
==========

Please send any comment on 'shuffle' or its documentation to
pallier@lscp.ehess.fr. If you like it and use it on a regular basis,
please let me know so that I can justify this work in my reports...

shuffle is distributed under the GNU licence (see shuffle -l)

Christophe Pallier (pallier@lscp.ehess.fr)
13 March 1999


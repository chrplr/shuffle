# Perl-Shuffle #

This is a Perl implementation of "shuffle", a program to generate random or pseudorandom permutations.

Shuffle reads lines and outputs them (or a subset of them) in a random
order, possibly with constraints on successive lines.  If no contraint
is specified, all permutations are equiprobable. Otherwise,
constraints can be specified as maximum number of repetitions of
labels in one or several columns of the output, or on the minimum
distance between successive repetitions.







## INSTALLATION ##


Shuffle requires Perl to be installed on your system (cf http://www.cpan.org).
The graphical, interactive version also requires the Tk module for Perl.

### Ubuntu ###

To install Perl and its Tk module under Ubuntu, type:

    sudo apt install perl perl-tk

To install shuffle, just copy the `*.pl` files in a directory which is in the path (e.g. /usr/local/bin).

Note: You may have to modify the first line of each script to reflect to
actual location of perl on your system.


### Windows ###

Perl does not come pre-installed with Windows. To work with Perl
programs on Windows, Perl will need to be manually downloaded and
installed. ActiveState offers a complete, ready-to-install version of
Perl for Windows.

http://www.activestate.com/activeperl/


Perl scripts should start with the path to Perl on the first line. The
path to Perl should be the location where you installed Perl on your
Windows machine.

## Array::Base module

You also need to install the ``Array::Base`` module, otherwise you will get the following error message when you tryto execute ``shuffle.pl``::

    $ perl shuffle.pl
    Can't locate Array/Base.pm in @INC (you may need to install the Array::Base module)

To install it under Linux,

    cpan   # to install cpan
    sudo perl -MCPAN -e 'install Array::Base'

To run the GUI version of the program, ``shuffle_tk.pl``, you may also need to install Tk:

    sudo perl -MCPAN -e 'install Tk'



General instructions to install perl modules are available at <http://www.cpan.org/modules/INSTALL.html>



## RUNNING ##

On the command-line, type `shuffle.pl` or `shuffle_tk.pl`



Please send any comment on 'shuffle' or its documentation to
christophe.pallier@m4x.org. 

If you like it and use it on a regular basis, please let me know so
that I can justify this work in my reports...

shuffle is distributed under the GNU licence (see shuffle -l)

Christophe Pallier (christophe.pallier@m4x.org)
Last update: 07/06/2001





                        

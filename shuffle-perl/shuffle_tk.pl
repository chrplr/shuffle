#!/usr/bin/perl -w
#
# Graphical Interface to shuffle
# Author: Christophe Pallier
# Date: July 2000
# License: GPL

use Tk;

$MW = MainWindow->new;

#####
$Top = $MW->Frame();

$t = $MW->Scrolled(
    qw/Text -wrap none -relief sunken -borderwidth 2
      -setgrid true -height 20 -scrollbars se/
);

$Bot1 = $MW->Frame();

$infoline = $MW->Label(
    -textvariable => \$info,
    -relief       => 'ridge'
)->pack(
    -side => 'bottom',
    -fill => 'x'
);

# Line 1
$Top->Button(
    -text    => 'Open File',
    -command => \&open_file
)->pack( -side => 'left' );

$Top->Button(
    -text    => 'Save as',
    -command => \&save_file
)->pack( -side => 'left' );

$Top->Button(
    -text    => 'Help',
    -command => \&show_help
)->pack( -side => 'left' );

$Top->Button(
    -text    => 'Quit',
    -command => sub { exit; }
)->pack( -side => 'left' );

$Top->pack( -side => 'top', -fill => 'x' );

# main text area
$t->pack(qw/-expand yes -fill both -side top/);

# shuffle command line
$Bot1->Button(
    -text    => 'Shuffle!',
    -command => \&shuffle_t
)->pack( -side => 'left' );

$iter = $Bot1->Entry( -width => 4 )->pack( -side => 'right' );

$Bot1->Label( -text => 'iterations=' )->pack( -side => 'right' );

$seed = $Bot1->Entry( -width => 6 )->pack( -side => 'right' );

$Bot1->Label( -text => 'Seed=' )->pack( -side => 'right' );

$constr = $Bot1->Entry()->pack( -side => 'right' );

$Bot1->Label( -text => 'Constraints=' )->pack( -side => 'right' );

$equi = 0;
$Bot1->Checkbutton( -variable => \$equi )->pack( -side => 'right' );

$Bot1->Label( -text => 'Equiprob:' )->pack( -side => 'right' );

$Bot1->pack( -side => 'bottom', -fill => 'x' );

MainLoop;

sub save_file {
    $fs   = $Top->getSaveFile();
    $fn   = $fs;
    $info = "Saving $fn...";
    if ( !open( FIC, ">$fn" ) ) {
        $info = $info . "error!";
        return;
    }
    else {
        print FIC $t->get( "1.0", "end" );
        close(FIC);
        $info = $info . "ok";
    }
}

sub open_file {
    $fn = $Top->getOpenFile();

    $info = "Loading '$fn'...";
    $t->delete( "1.0", "end" );
    if ( !open( FIC, "$fn" ) ) {
        $info = "Error: cannot open file '$fn'";
        return;
    }
    while (<FIC>) { $t->insert( "end", $_ ); }
    close(FIC);
    $info = "'$fn' loaded'";
}

sub shuffle_t {
    $options = "";
    if ( $constr->get ) {
        $options = "-c\"" . $constr->get() . "\"";
    }
    if ( $seed->get ) {
        $options = $options . " -s\"" . $seed->get() . "\"";
    }
    if ( $equi == 1 ) {
        $options = $options . " -e";
        if ( !$iter->get() ) { $iter->insert( "end", '100' ); }
    }
    if ( $iter->get() ) {
        $options = $options . " -i" . $iter->get();
    }
    print $options. "\n";
    open( OUTPUT, "|./shuffle.pl $options >tmpfile" );
    $info = "Shuffling...";
    $infoline->update();
    print OUTPUT $t->get( "1.0", "end" );
    close(OUTPUT);
    $t->delete( "1.0", "end" );
    open( AGA, "<tmpfile" );
    $n = 0;

    while (<AGA>) {
        $t->insert( "end", $_ ) unless ( $_ eq "\n" );
        $n++;
    }
    $info = "$n lines processed.";
    $infoline->update();
}

sub show_help {
    $Helptxt =
        "\"Shuffle\" randomly permutates the lines contained in this window.\n"
      . "Optionaly, one can set constraints on the admissible permutations
 (see below) and/or specify the seed used by the random generator. (A
 given number, as seed, yields systematically the same permutation.)\n\n"
      . "Constraints:\n"
      . " When the text is in tabular format (that is organised in columns
 delimited by white-spaces), constraints can be enforced, column by
 column, either on the maximun number of successive lines with a
 constant label, or on the minimum number of lines that must separate
 two occurrences of the same label.\n\n"
      . "Constraints are specified as a series of numbers, one for each column.\n"
      . " - a positive number 'n' indicates that labels should not be repeated\nmore than 'n' times in a row.\n"
      . " - a negative number '-m' indicates that occurences of similar labels\nshouldbe spearated by at least 'm' lines.\n"
      . " - a zero indicates that there are no particular constraints.\n\n"
      . "Examples.\n 1. Suppose the text describes the materials for a
 lexical decision experiment: each line might contain three columns:
 first the item, then a label specifing the level a frequency factor
 ('HF' or 'LF', for high or low frequency), and finally the response
 'Yes', 'No'. Putting '0 2 3' in the 'constraints' field, will produce
 a list that has no more than 2 succesive trials with the same
 frequency range, and no more than 3 successive trials with the same
 response.\n\n"
      . "2. Suppose your material contains 10 targets and 90 distractors, 
 and you want successive targets to be separated by at least 3
 distractors. One column must contain the label 'target' or
 'distractorxx' where xx is the distractor nnumber. Then, setting the
 constraint to '-4' in the position of the relevant column will
 produce the desired result.\n\n"
      . "When no constraint is specified all permutations are equiprobable.\n"
      . "When constraints are specified, the default algorithm is a constructive "
      . "one which will about always find a solution.\n"
      . "However, all permutations are not equiprobable.\n"
      . "If the 'Equiprob' box is checked, all permutations are equiprobable:\n"
      . "A simple filter is applied to check if the permutation fullfills the constraints."
      . "This garantees equiprobability but is a very inefficient search in the space of permutations"
      . "This means that the algorithm will often fail to find a solution\n"
      . "when the constraints are hard to fullfill.\n\n"
      . "This program is free software distributed under the terms of the GNU
 licence (see http://www.gnu.org)\n\n"
      . "Check out the author web site (www.pallier.org) for additionnal information.\n"
      . "Reports bugs to christophe.pallier\@m4x.fr\n";

    $t->delete( "1.0", "end" );
    $t->insert( "end", $Helptxt );
}


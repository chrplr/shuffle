#! /usr/bin/perl
#
# Note: you may have to modify the first line above to reflect the location
# of `perl' on your system. Under unix, type `which perl' to determine it. 
#
# Shuffle performs a random permutation on the lines from the standard input,
# with possible constraints on successive lines.
#
# Version 1.0 (perl)
# Author: Christophe Pallier (pallier@lscp.ehess.fr)
# Date: 13 Mar. 1999 (awk) 20 July 2000 (perl)
#
# cf. www.pallier.org for a paper describing "shuffle" in details.
#
# This program is copyrighted under the terms of the GNU 
# license (see http://www.gnu.org).
#
# Options 
#   -c 'n1 n2 ... '  constraints
#   -s xxx           seed
#   -n xxx           number of output lines 
#   -i xxx           maximum number of iterations
#   -e               turns on the algorithm "equiprobable permutations" 

use Getopt::Std;

use strict;

$[ = 1;			# set array base to 1
$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

my $ExitValue = 0;

#####################################
# process command line options

my %opts;

getopts("h?ls:c:n:i:e",\%opts);

if ($opts{'h'} || $opts{'?'})  {
    usage();
    $ExitValue = 1; 
    last line;
}

if ($opts{'l'}) {
    license();
    $ExitValue = 1; 
    last line;
}



# set randomizer's seed 
if ($opts{'s'}) {
    srand($opts{'s'});
} 

##############################################
# reads the input lines and store them in 'table'
# eliminating empty lines

my @table=();

while (<>) {
  chop;
  push(@table, $_) unless ($_ eq ""); 
}

my $nlines=$#table;
my $n=$nlines;

if ($opts{'n'}) { $n=$opts{'n'}; }

my $iter=$nlines;
if ($opts{'i'}) { $iter=$opts{'i'}; }

if (!$opts{'c'}) { 
    
    permute(\@table,$n); # generate an unconstrained, random, permutation 

    for (my $i=$nlines-$n+1;$i<=$nlines;$i++)
    { 
	print $table[$i];
    }
}
else
{
    my $constr=$opts{'c'};

    if ($opts{'e'})
    { # generate random permutations until one fullfills the constraints
      # or the maximum number of iterations is reached.
	my $loop=1; 
	do { permute(\@table,$#table); } 
	until (filter(\@table,$constr,$n) or ($loop++>$iter));
	if ($loop>$iter) { $ExitValue=1; }
    }
    else 
    { # build a permutation that fullfills the constraints
	shuffle(\@table,$constr,$n,$iter) || ($ExitValue=1);
    }


    if ($ExitValue==0) {
       for (my $i = 1; $i <= $n; $i++) 
       {
	print $table[$i];
       }
    }
    else { print STDERR "Shuffle could not find a solution. Try again"; }
}
exit $ExitValue;


########################## subroutine shuffle ###############
sub shuffle {
    my $table = shift;
    my $constr= shift;
    my $n = shift;
    my $iter = shift;

# return 0 if no solution, 1 else. 
#  print @table;

  if ($constr eq "") {
      permute(\@table,$n);
      return 1;
  }

my @constraint = split(' ', $constr);

my $loop = 0;
my $MaxLoops = $iter ? $iter : $nlines;
my $output_nlines = $n ? $n : $nlines;

my @rep;
my @prev;
my @current;
my @tmp;
my ($nf,$pass_line,$fail,$bad_permut);
my ($i,$j,$k,$back,$ll);

do {
    permute(\@table, $#table);
    $bad_permut = 0;    # will be set to 1 if the permutation is bad...
    $loop++;

    # scan the table line by line
    # swapping lines to try and respect the constraints

    $nf = (@prev = split(' ', $table[1]));

    for ($k = 1; $k <= $nf; $k++) {
	$rep[$k] = 1;	# rep[k]=number of repetitions in column [k]
    }
    for ($i = 2; (!$bad_permut) and ($i <= $output_nlines); $i++) {	
	$pass_line = 0;
	for ($j = $i; (!$pass_line) and ($j <= $nlines); $j++) {	
	    $nf = (@current = split(' ', $table[$j]));
	    $fail = 0;
	    for ($k = 1; (!$fail) and ($k <= $nf); $k++) {	

		if ($constraint[$k]>0) { 
		    if (($prev[$k] eq $current[$k]) and 
			($rep[$k] + 1 > $constraint[$k])) {
			$fail = 1;
		    }
		}

		if ($constraint[$k]<0) { 
		    $back=$i-(-$constraint[$k]);
		    if ($back<1) { $back=1; }; 
		    for ($ll = $back; ($ll < $i) and (!$fail);$ll++) {
			@tmp=split(' ',$table[$ll]);
			if ($tmp[$k] eq $current[$k]) {
			    $fail=1;
			}
		    }
		}

	    } # next k
	    if ($fail == 0) {
		$pass_line = 1;
	    }
	} # next j
	# now, if pass_line==1, line j fulfills the constraints
	if ($pass_line) {
	    $j--;
	    if ($j > $i) { 
		swap(\@table, $i, $j);
	    }
	    for ($k = 1; $k <= $nf; $k++) {
		if ($prev[$k] eq $current[$k]) {       
		    $rep[$k]++;
		}
		else {
		    $rep[$k] = 1;
		}
		$prev[$k] = $current[$k];
	    }
	}
	else {
	    # it is not possible to rearrange this permutation;
	    # let's try another one.
	    $bad_permut = 1;
	}
    }
    # next i
} while ( $bad_permut & ($loop < $MaxLoops));  

if ($bad_permut) { 0 } 
else { 1 } 

}

sub swap {
    my $array = shift;
    my $i = shift;
    my $j = shift;
    @$array[$i,$j]=@$array[$j,$i];
}


sub permute {
# random permutation of array's elements
# only the "size" last elements are randomized

    my $array = shift;
    my $size = shift;
    my $i;
    my $j;

    for ($i = $size; $i > 1; $i--) {
	$j = 1 + int(rand(1) * $i);
	@$array[$i,$j] = @$array[$j,$i];
    }
}


sub filter  {
# this routine just checks if a permutation respects the constraints
# returning 1 if pass or 0 if failure
  my $table = shift;
  my $constr = shift;
  my $nlines = shift;


  my @constraint = split(' ', $constr);

  my @prev;
  my  $nf = (@prev = split(' ', $table[1]));

  my @current;
  my @tmp;
  my @rep;
  my $back;

    for (my $k = 1; $k <= $nf; $k++) {
	$rep[$k] = 1;	# rep[k]=number of repetitions in column [k]
    }

    for (my $i = 2; $i <= $nlines; $i++) {	
	    $nf = (@current = split(' ', $table[$i]));
	    my $fail = 0;
	    for (my $k = 1; (!$fail) and ($k <= $nf); $k++) {	

		if ($constraint[$k]>0) { 
		    if (($prev[$k] eq $current[$k]) and 
			($rep[$k] + 1 > $constraint[$k])) {
			$fail = 1;
			return 0;
		    }
		}

		if ($constraint[$k]<0) { 
		    $back=$i-(-$constraint[$k]);
		    if ($back<1) { $back=1; }; 
		    for (my $ll = $back; ($ll < $i) and (!$fail);$ll++) {
			@tmp=split(' ',$table[$ll]);
			if ($tmp[$k] eq $current[$k]) {
			    $fail=1; 
			    return 0;
			}
		    }
		}

	    } # next k

	    for (my $k = 1; $k <= $nf; $k++) {
		if ($prev[$k] eq $current[$k]) {       
		    $rep[$k]++;
		}
		else {
		    $rep[$k] = 1;
		}
		$prev[$k] = $current[$k];
	    }

    }
    # next i
return 1; 

}



sub usage {
    my $usage_str = '' .
      "Shuffle performs a random permutation on the lines from the standard input,\n"
      . "optionnaly enforcing constraints.\n" .
      "Usage:\n   shuffle [-e] [-c\"n1 n2...\"] [-n<num>] [-s<num>] [-i<num>]\n".
      "Options:\n" .
      "-n<num>     : output 'num' lines\n" .
      "-s<num>     : set the seed for the random number generator to <num>\n".
      "-c'n1 n2...': set constraints on maximum number of repetitions in columns\n".
      " -e         : select the algorithm making all constrained permutations equiprobable (this may fail to converge to a solution)\n" .
      "-i<num>     : maximum number of iterations\n" .
      "-h|-? : shows this help\n" . "-l   : displays the license\n\n" .
      "shuffle reads the lines from the standard input or from a file given\n".
      "as argument, and outputs them in a random order, with possible restrictions:\n"
      . "\nWithout the option '-c' any permutation can be applied.\n"
      . "Otherwise, the ith number in the argument to '-c'\n"
      . "specifies the maximum\n" .
      "number of repetitions in ith column of the output.\n\n" .

      "Author: Christophe Pallier (pallier\@lscp.ehess.fr).\n" .
      "Date: 13 March 1999\n" .
      'This program is distributed under the terms of the GNU License (type "shuffle -l")';
    print $usage_str;
}

sub license {
    my $lic =
      " Shuffle - performs a random permutation on the lines from the standard input,\n"
      . " with possible restrictions.\n" .
      " Copyright (C) 1999 Christophe Pallier (pallier\@lscp.ehess.fr)\n\n" .
      " This program is free software; you can redistribute it and/or\n" .
      " modify it under the terms of the GNU General Public License\n" .
      " as published by the Free Software Foundation; either version 2\n" .
      " of the License, or (at your option) any later version.\n" .
      "\n This program is distributed in the hope that it will be useful,\n" .
      " but WITHOUT ANY WARRANTY; without even the implied warranty of\n" .
      " MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n" .
      " GNU General Public License for more details.\n" .
      "\n You should have received a copy of the GNU General Public License along\n"
      . " with this program; if not, write to the Free Software Foundation, Inc.,\n"
      . ' 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA. (www.gnu.org)';
    print $lic;
    $ExitValue = 1; last line;
}



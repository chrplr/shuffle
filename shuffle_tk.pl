#!/usr/bin/perl -w
#
# Graphical Interface to shuffle
# Author: Christophe Pallier
# Date: July 2000
# License: GPL

use Tk;

$[ = 1;			# set array base to 1


$MW = MainWindow->new;

##### 
$Top = $MW->Frame();

$t = $MW->Scrolled(qw/Text -wrap none -relief sunken -borderwidth 2
-setgrid true -height 20 -scrollbars se/);



$Bot1 = $MW->Frame();

$infoline = $MW->Label(-textvariable => \$info,
	   -relief => 'ridge')->pack(-side => 'bottom',
				     -fill => 'x');

# Line 1
$Top->Button(-text => 'Open File',
	     -command => \&open_file
	     )->pack(-side=>'left');


$Top->Button(-text => 'Save as',
	     -command => \&save_file
	     )->pack(-side=>'left');


$Top->Button(-text => 'Help', 
	     -command => \&show_help
	     )->pack(-side=>'left');

$Top->Button(-text => 'Quit', 
	     -command => sub { exit; }
	     )->pack(-side=>'left');

$Top->pack(-side => 'top', -fill=>'x');

# main text area
$t->pack(qw/-expand yes -fill both -side top/);

# shuffle command line
$Bot1->Button(-text    => 'Shuffle!', 
	     -command => \&shuffle_t 
	    )->pack(-side=>'left');

$nout = $Bot1->Entry(-width =>3)->pack(-side => 'right');

$Bot1->Label(-text=>'N=')->pack(-side => 'right');

$iter = $Bot1->Entry(-width => 4)->pack(-side => 'right');

$Bot1->Label(-text=>'Iterations=')->pack(-side=>'right');

$seed = $Bot1->Entry(-width => 6)->pack(-side => 'right');

$Bot1->Label(-text =>'Seed=')->pack(side => 'right');

$constr = $Bot1->Entry()->pack(-side => 'right');

$Bot1->Label(-text => 'Constraints=')->pack(-side => 'right');

$equi=0;
$Bot1->Checkbutton(-variable=>\$equi)->pack(-side=>'right');

$Bot1->Label(-text => 'Equiprob:')->pack(-side=>'right');

$Bot1->pack(-side => 'bottom', -fill=>'x');


MainLoop; 

sub save_file {
$fs = $Top->getSaveFile();
    $fn=$fs;
    $info="Saving $fn...";
    if (!open(FIC,">$fn")) {
	$info =  $info . "error!";
	return;
    } else {
    print FIC $t->get("1.0","end"); 
    close(FIC);
    $info=$info . "ok";
    }    
}

sub open_file {
    $fn=$Top->getOpenFile();
    
    $info = "Loading '$fn'...";
    $t->delete("1.0","end");
    if (!open(FIC,"$fn")) {
	$info = "Error: cannot open file '$fn'";
	return;
    }
    $n=0;
    while (<FIC>) { $t->insert("end",$_); $n++; }
    close (FIC);
    $info = "'$fn' : $n lines read";
}

sub shuffle_t {

    @table=split("\n",$t->get("1.0","end"));

    $n=$#table;
    if ($nout->get()) { $n=$nout->get(); }

    if ($seed->get()) 
    { 
      srand($seed->get());
    }

    if ($iter->get()) { $maxloop=$iter->get(); }
    else { $maxloop=$#table*10; }


    if (!$constr->get()) 
    {
	&permute(*table,$#table);
	$ok=1;
    }
    elsif ($equi==1) 
    {
	    # generate random permutations until one fullfills the constraints
            # or the maximum number of iterations is reached.
	$loop=1; 
        
	do { 
	    &permute(*table,$#table); 
	    $info="iter. \# $loop";  
	    $infoline->update(); 
	} until (($ok = &filter(*table,$constr->get(),$n)) or ($loop++>$maxloop));
    } 
    else 
    { # use the constructive algorithm

	    $ok = &shuffle(*table,$constr->get(),$n,$maxloop);
    }
    
    if ($ok) 
    {
	$t->delete("1.0","end");
	for ($i=1;$i<=$n;$i++) {
	    $t->insert("end",$table[$i]."\n");
	}
	$info="$n lines processed.";
    }
    else
    { $info="The algorithm did not find a solution. Try again";
    }
    $infoline->update();
}



########################## subroutine shuffle ###############
sub shuffle {
  local(*table,$constr,$n,$iter)=@_;
# return 0 if no solution, 1 else. 
#  print @table;

@constraint = split(' ', $constr);

$loop = 0;
$MaxLoops = $iter ? $iter : $nlines;
$output_nlines = $n ? $n : $nlines;
$nlines = $#table;

do {
    &permute(*table, $#table);
    $bad_permut = 0;    # will be set to 1 if the permutation is bad...
    $loop++;

    # scan the table line by line
    # swapping lines to try and respect the constraints

    $nf = (@prev = split(' ', $table[1]));
    for ($i=$#constraint+1;$i<=$nf;$i++) { $constraint[$i]=0; }

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
		&swap(*table, $i, $j);
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
    local(*table,$i,$j)= @_;
# exchanges the ith and jht element from table
    
    if ($i != $j) {	
	$temp = $table[$i];
	$table[$i] = $table[$j];
	$table[$j] = $temp;
    }
}

sub permute {
    local(*array, $size) = @_;
# random permutation of array's elements
    local($i);
    for ($i = $size; $i > 1; $i--) {
	&swap(*array, $i, 1 + int(rand(1) * $i));
    }
}


sub filter  {
# this routine just checks if a permutation respects the constraints
# returning 1 if pass or 0 if failure
  local(*table,$constr,$nlines)=@_;

  @constraint = split(' ', $constr);

    $nf = (@prev = split(' ', $table[1]));
    for ($k = 1; $k <= $nf; $k++) {
	$rep[$k] = 1;	# rep[k]=number of repetitions in column [k]
    }
    for ($i = 2; $i <= $nlines; $i++) {	
	    $nf = (@current = split(' ', $table[$i]));
	    $fail = 0;
	    for ($k = 1; (!$fail) and ($k <= $nf); $k++) {	

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
		    for ($ll = $back; ($ll < $i) and (!$fail);$ll++) {
			@tmp=split(' ',$table[$ll]);
			if ($tmp[$k] eq $current[$k]) {
			    $fail=1; 
			    return 0;
			}
		    }
		}

	    } # next k

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
    # next i
return 1; 

}


sub show_help { 
$Helptxt="\"Shuffle\" randomly permutates the lines contained in this window.\n" . 
 "Optionaly, one can set constraints on the admissible permutations
 (see below) and/or specify the seed used by the random generator. (A
 given number, as seed, yields systematically the same permutation.)\n\n" . 
 "Constraints:\n" .
 " When the text is in tabular format (that is organised in columns
 delimited by white-spaces), constraints can be enforced, column by
 column, either on the maximun number of successive lines with a
 constant label, or on the minimum number of lines that must separate
 two occurrences of the same label.\n\n".
 "Constraints are specified as a series of numbers, one for each column.\n".
 " - a positive number 'n' indicates that labels should not be repeated\nmore than 'n' times in a row.\n".
 " - a negative number '-m' indicates that occurences of similar labels\nshouldbe spearated by at least 'm' lines.\n".
 " - a zero indicates that there are no particular constraints.\n\n" .
 "Examples.\n 1. Suppose the text describes the materials for a
 lexical decision experiment: each line might contain three columns:
 first the item, then a label specifing the level a frequency factor
 ('HF' or 'LF', for high or low frequency), and finally the response
 'Yes', 'No'. Putting '0 2 3' in the 'constraints' field, will produce
 a list that has no more than 2 succesive trials with the same
 frequency range, and no more than 3 successive trials with the same
 response.\n\n".
 "2. Suppose your material contains 10 targets and 90 distractors, 
 and you want successive targets to be separated by at least 3
 distractors. One column must contain the label 'target' or
 'distractorxx' where xx is the distractor nnumber. Then, setting the
 constraint to '-4' in the position of the relevant column will
 produce the desired result.\n\n".
 "When no constraint is specified all permutations are equiprobable.\n".
 "When constraints are specified, the default algorithm is a constructive " .
 "one which will about always find a solution.\n" .
"However, all permutations are not equiprobable.\n" .
 "If the 'Equiprob' box is checked, all permutations are equiprobable:\n".
"A simple filter is applied to check if the permutation fullfills the constraints." .  "This garantees equiprobability but is a very inefficient search in the space of permutations" . "This means that the algorithm will often fail to find a solution\n". "when the constraints are hard to fullfill.\n\n" .
 "This program is free software distributed under the terms of the GNU
 licence (see http://www.gnu.org)\n\n" .
 "Check out the author web site (www.pallier.org) for additionnal information.\n".
 "Reports bugs to christophe.pallier\@m4x.fr\n";

        $t->delete("1.0","end"); 
	$t->insert("end",$Helptxt);
} 









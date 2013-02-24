#!/usr/bin/perl
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;
			# this emulates #! processing on NIH machines.
			# (remove #! line above if indigestible)

#computes the distributions of runs

$a = <>;
chop $a;
$n = 1;

while (<>) {
    chop;
    if ($a ne $_) {
	    $run{$a . " * " . $n}++;
	    $n = 1;
	    $a = $_;
    }
    else {
	    $n++;
    }
}

print "label *  rows : count\n ";
foreach $i (sort(keys %run)) {
    print $i . " : " . $run{$i} . "\n";
}


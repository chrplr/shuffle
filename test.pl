#!/usr/bin/perl
use Getopt::Std;

getopts("hs:",\%opts);

print $opts{'h'} . " " . $opts{'s'};





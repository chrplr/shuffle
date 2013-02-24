#!/usr/bin/awk -f
#computes the distributions of runs

NR==1 { a=$0; n=1; }
NR>1  { if (a!=$0) { run[$a,n]++; n=1; a=$0;} else n++ }

END{ for (i in run) { print i,run[i]; }}

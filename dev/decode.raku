#!/usr/bin/env raku

use lib <../lib>;

my $debug = 0;
my $s = "),typ(r ) ;fmt ( s) rtn( li) ";

# remove all whitepace, semicolons, and commas
say "\$s original: |$s|" if $debug;
$s ~~ s:g/\s//;
$s ~~ s:g/';'//;
$s ~~ s:g/','//;
say "\$s cleaned: |$s|" if $debug;

if $s ~~ /:i 'typ(' (\S+) ')' / {
}
if $s ~~ /:i 'fmt(' (\S+) ')' / {
}
if $s ~~ /:i 'rtn(' (\S+) ')' / {
}


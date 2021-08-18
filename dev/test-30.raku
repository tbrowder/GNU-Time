#!/usr/bin/env raku

use Test;
use File::Temp;

use lib <../lib>;
use GNU::Time;

my $prog = q:to/HERE/;
my $i = 0;
for 1..100 {
    $i += 2;
}
HERE

my ($prog-file, $fh) = tempfile;
$fh.print: $prog;
$fh.close;

my $cmd = "raku $prog-file";

my ($res, $typ, $fmt, $rtn);
my $debug = 0;

my @typ = <r real u user s sys + u+s>;
my @fmt = <s seconds h hms : h:m:s>;
my @rtn = <l list h hash>;
my $tn = 0; # for debugging, test number, check a bad or unknown command

dies-ok { $res = time-command 'fooie', :$fmt };
say "debug: test { ++$tn }" if $debug;

# check the defaults
lives-ok { $res = time-command $cmd };
say "debug: test { ++$tn }; \$res = '$res'" if $res && $debug;

# need a subroutine to check $res with like

# check the default for the $typ arg
for @typ -> $typ {
    lives-ok { $res = time-command $cmd, :$typ };
    say "typ = '$typ', res = '$res'";
}

=finish

# check the default for the typ arg
for @fmt -> $fmt {
    lives-ok { $res = time-command $cmd, :$fmt };
}

# check all arg combinations
for @typ -> $typ {
    for @fmt -> $fmt {
        lives-ok { $res = time-command $cmd, :$typ, :$fmt };
    }
}

# check the :$list param
$fmt = 's';
$typ = 's';
my $list = True;
my @res;
lives-ok { @res = time-command $cmd, :$typ, :$fmt, :$list };
$res = join ' ', @res;

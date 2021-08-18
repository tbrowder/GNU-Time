use Test;
use GNU::Time :ALL;

# This series of tests is for the "internal" routines
# in the module.

plan 14;

my $debug = 0;

# An example time string for use as the output from the time-command'
# routine for further processing:
constant time = "real 0.23\nuser 0.22\nsys 0.01\n";

my @typ = <r real u user s sys + u+s>;
for @typ -> $typ {
    my $res = read-sys-time time, :$typ;
    if $typ ~~ /^r/ {
        is $res, "0.23";
    }
    elsif $typ ~~ /'+'/ {
        is $res, "0.23";
    }
    elsif $typ ~~ /^u/ {
        is $res, "0.22";
    }
    elsif $typ ~~ /^s/ {
        is $res, "0.01";
    }
}

my @fmt = <s seconds h hms : h:m:s>;
my $typ = "user";
for @fmt -> $fmt {
    my $res = read-sys-time time, :$fmt, :$typ;
    if $fmt ~~ /^s/ {
        is $res, "0.22s";
    }
    elsif $fmt ~~ /':'/ {
        is $res, "0:00:00.22";
    }
    elsif $fmt ~~ /^h/ {
        is $res, "0h00m00.22s";
    }
}

=finish

my @rtn = <l list h hash>;

my $time;

# tests 1-4
dies-ok { time-command 'fooie'; }
dies-ok { time-command 'fooie', :dir($*TMPDIR); }
lives-ok { $time = time-command 'ls -l', :dir($*TMPDIR); }
say "DEBUG: \$time = '$time'" if $debug;
cmp-ok $time, '>=', 0;

# tests 5-8
lives-ok { $time = time-command 'ls -l'; }
cmp-ok $time, '>=', 0;
lives-ok { $time = time-command 'ls -l', :dir($*TMPDIR); }
cmp-ok $time, '>=', 0;

# run some real commands with errors
# get a prog with known output
my $prog = q:to/HERE/;
$*ERR.print: 'stderr';
$*OUT.print: 'stdout';
HERE

my ($prog-file, $fh) = tempfile;
$fh.print: $prog;
$fh.close;

my $cmd = "raku $prog-file";

# run tests in the local dir
# tests 9-10
lives-ok { $time = time-command $cmd; }
cmp-ok $time, '>', 0;

# run tests in the tmp dir
my $f = "prog-file";
my $fh2 = open "$*TMPDIR/$f", :w;
$fh2.print: $prog;
$fh2.close;

# tests 11-12
$cmd = "raku $f";
lives-ok { $time = time-command $cmd, :dir($*TMPDIR); }
say "DEBUG: \$time = '$time'" if $debug;
cmp-ok $time, '>', 0;

# one more test
# test 13
dies-ok { time-command "cd $*TMPDIR; fooie"; }

use v6;

use Test;

use File::Temp;

use GNU::Time;

plan 131;

my token num { \d+ [ \. \d* ]? }
my token typR { :i real }
my token typU { :i user }
my token typS { :i sys  }

my token typr { :i real ':' }
my token typu { :i user ':' }
my token typs { :i sys ':' }
my token typ { <typr> | <typu> | <typs> }
my token s { :i <num> s }
my token h { :i <num> h <num> m <num> s }
my token H { <num> ':' <num> ':' <num> }

my token default { <typR> \s+ <num> \s+ <typU> \s+ <num> \s+ <typS> \s+ <num> }
my token an { <typr> \s* <num> ';' \s* <typu> \s* <num> ';' \s* <typs> \s* <num> }
my token as { <typr> \s* <s>   ';' \s* <typu> \s* <s>   ';' \s* <typs> \s* <s>   }
my token ah { <typr> \s* <h>   ';' \s* <typu> \s* <h>   ';' \s* <typs> \s* <h>   }
my token aH { <typr> \s* <H>   ';' \s* <typu> \s* <H>   ';' \s* <typs> \s* <H>   }

my token list { :i
                real \t <h> \s*
                user \t <h> \s*
                sys  \t <h> \s* }

my token hash { :i
                real \t <h> \s*
                user \t <h> \s*
                sys  \t <h> \s* }

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
note "debug: test { ++$tn }" if $debug;

# check the defaults
lives-ok { $res = time-command $cmd };
note "debug: test { ++$tn }; \$res = '$res'" if $res && $debug;
like $res, &num;
note "debug: test { ++$tn }; \$res = '$res'" if $res && $debug;

# need a subroutine to check $res with like
sub check($res, :$typ, :$fmt, :$rtn) {
    # rtn overrides all
    if $rtn {
        if $rtn ~~ /^ :i l/ {
            like $res, &num;
        }
        elsif $rtn ~~ /^ :i h/ {
            like $res, &num;
        }
        return;
    }

    if not ($fmt or $typ) {
        like $res, &default;
        return;
    }

    if !$fmt {
        if $typ ~~ /^r/ {
            like $res, &num;
        }
        elsif $typ ~~ /^s/ {
            like $res, &num;
        }
        elsif $typ ~~ /'+'/ {
            like $res, &num;
        }
        elsif $typ ~~ /^u/ {
            like $res, &num;
        }
        else {
            die "FATAL: Unexpected \$typ: '$typ'";
        }
    }
    elsif $fmt ~~ /^s/ {
        if !$typ {
            like $res, &s;
        }
        elsif $typ ~~ /^r/ {
            like $res, &s;
        }
        elsif $typ ~~ /^s/ {
            like $res, &s;
        }
        elsif $typ ~~ /'+'/ {
            like $res, &s;
        }
        elsif $typ ~~ /^u/ {
            like $res, &s;
        }
        else {
            die "FATAL: Unexpected \$typ: '$typ'";
        }
    }
    elsif $fmt ~~ /':'/ {
        if !$typ {
            like $res, &H;
        }
        elsif $typ ~~ /^r/ {
            like $res, &H;
        }
        elsif $typ ~~ /^s/ {
            like $res, &H;
        }
        elsif $typ ~~ /'+'/ {
            like $res, &H;
        }
        elsif $typ ~~ /^u/ {
            like $res, &H;
        }
        else {
            die "FATAL: Unexpected \$typ: '$typ'";
        }
    }
    elsif $fmt ~~ /^h/ {
        if !$typ {
            like $res, &h;
        }
        elsif $typ ~~ /^r/ {
            like $res, &h;
        }
        elsif $typ ~~ /^s/ {
            like $res, &h;
        }
        elsif $typ ~~ /'+'/ {
            like $res, &h;
        }
        elsif $typ ~~ /^u/ {
            like $res, &h;
        }
        else {
            die "FATAL: Unexpected \$typ: '$typ'";
        }
    }
    else {
        die "FATAL: Unexpected \$fmt: '$fmt'";
    }

}

# check the typ arg
for @typ -> $typ {
    lives-ok { $res = time-command $cmd, :$typ };
    note "debug: test { ++$tn }; \$typ = '$typ'; \$res = '$res'" if $debug;
    check $res, :$typ;
    note "debug: test { ++$tn }" if $debug;
}


# check the fmt arg
for @fmt -> $fmt {
    if not $fmt {
        note "DEBUG: skipping unexpected empty fmt";
        next;
    }

    lives-ok { $res = time-command $cmd, :$fmt };
    note "debug: test { ++$tn }; \$fmt = '$fmt'; \$res = '$res'" if $debug;
    check $res, :$fmt;
    note "debug: test { ++$tn }" if $debug;
}

# check all arg combinations
for @typ -> $typ {
    for @fmt -> $fmt {
        lives-ok { $res = time-command $cmd, :$typ, :$fmt };
        note "debug: test { ++$tn }; \$typ = '$typ'; \$fmt = '$fmt'; \$res = '$res'" if $debug;
        check $res, :$typ, :$fmt;
        note "debug: test { ++$tn }" if $debug;
    }
}

# check the :$rtn param
$fmt = 's';
$typ = 's';
$rtn = 'l';
my @res;
lives-ok { @res = time-command $cmd, :$typ, :$fmt, :$rtn };
$res = join ' ', @res;
note "debug: test { ++$tn }; \$typ = '$typ'; \$fmt = '$fmt', \$rtn = '$rtn'; \$res = '$res'" if $debug;
check $res, :$typ, :$fmt, :$rtn;
note "debug: test { ++$tn }" if $debug;

$rtn = 'h';
lives-ok { @res = time-command $cmd, :$typ, :$fmt, :$rtn };
$res = join ' ', @res;
check $res, :$typ, :$fmt, :$rtn;
note "debug: test { ++$tn }" if $debug;

use Test;
use GNU::Time :ALL;

# This series of tests is for the "internal" routines
# in the module.

plan 20;

my $debug = 0;

my ($typ, $fmt, $rtn);

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
$typ = "user";
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

# Test the GNU_Time_Format environment variable
%*ENV<GNU_Time_Format> = "typ(u)fmt(h)";

($typ, $fmt, $rtn) = decode-gnu-time-format;
is $typ, "u";
is $fmt, "h";

%*ENV<GNU_Time_Format> = "typ(s)fmt(:)";
($typ, $fmt, $rtn) = decode-gnu-time-format;
is $typ, "s";
is $fmt, ":";

%*ENV<GNU_Time_Format> = "typ (+ )fmt(s )";
($typ, $fmt, $rtn) = decode-gnu-time-format;
is $typ, "+";
is $fmt, "s";


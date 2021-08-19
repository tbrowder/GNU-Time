unit module GNU::Time:ver<0.0.1>:auth<cpan:TBROWDER>;

use Proc::Easy;

constant $gte = "GNU_Time_Format"; # environment variable

# need some regexes to make life easier
# Note you must choose either the one-character form
# or at least the first two characters of the multi-character form.
my token typ { ^ :i
    # the desired time(s) to return:
              # [default: all are returned]
    r|real|   # show real (wall clock) time only
    u|user|   # show the user time only
    s|sys|    # show the system time only
    '+'|'u+s' # show sum of user and system time
$ }

my token fmt { ^ :i
    # the desired format for the time(s)
                # [default: raw seconds]
    s|seconds|  # time in seconds with an appended
                #   's': "30.42s"
    h|hms|      # time in hms format: "0h00m30.42s"
    ':'|'h:m:s' # time in h:m:s format: "0:00:30.42"
$ }

my token rtn { ^ :i
    # the desired type of return:
    # [default: string]
    l|list|  
    h|hash
$ }

#------------------------------------------------------------------------------
# Subroutine: read-sys-time
# Purpose : An internal helper function that is not exported unless explicitly requested.
# Params  : A string that contains output from the GNU 'time' command, and three named parameters that describe which type of time values to return and in what format.
# Returns : A string consisting in one or all of real (wall clock), user, and system times (in one of four formats), or a list as in the original API.
sub read-sys-time($Result,
                  :$typ where { !$typ.defined || $typ ~~ &typ }, # see token 'typ' definition
                  :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                  :$rtn where { !$rtn.defined || $rtn ~~ &rtn }, # see token 'rtn' definition
                  :$debug,
                 ) is export(:read-sys-time) {

    note "DEBUG: time result '$Result'" if $debug;
    # get the individual seconds for each type of time
    my ($Rtr, $Utr, $Str); # raw values
    for $Result.lines -> $line {
	note "DEBUG: line: $line" if $debug;

	my $type = $line.words[0];
	my $sec = $line.words[1];
	given $type {
            when /real/ {
                $Rtr = $sec;
            }
            when /user/ {
                $Utr = $sec;
            }
            when /sys/ {
                $Str = $sec;
            }
            default {
                if $line ~~ /exit|code/ && $line ~~ / (\d+) / {
                    my $exitcode = +$0;
                    die "FATAL: The timed command returned a non-zero exitcode: $exitcode";
                }
            }
	}
    }

    # return as desired by the user
    my ($real, $user, $sys, $sum);

    if !$fmt.defined {
        # returning raw seconds
        $real = $Rtr;
        $user = $Utr;
        $sys  = $Str;
        $sum  = $user + $sys;
    }
    else {
        $real = seconds-to-hms $Rtr, :$fmt;
        $user = seconds-to-hms $Utr, :$fmt;
        $sys  = seconds-to-hms $Str, :$fmt;
        $sum  = seconds-to-hms $Utr + $Str, :$fmt;
    }

    if $rtn.defined {
        if $rtn ~~ /^l/ {
            # create and return a list
            return $real, $user, $sys;
        }
        elsif $rtn ~~ /^h/ {
            # create and return a hash
            return %(real => $real, user => $user, sys => $sys, system => $sys);
        }
	else { 
            die "FATAL: Unknown \$rtn option '$_'"
        }
    }

    # if no type is defined, reassemble and return the string
    if not $typ.defined {
        return "real $real\nuser $user\nsys $sys\n"
    }

    if not $typ {
        die qq:to/HERE/;
        FATAL: Unexpectedly \$typ is an empty string.
        Please file a bug report.
        HERE
    }

    # returning single values
    my $result;
    given $typ {
        when /^ :i r/ {
            $result = $real
        }
        when / '+'/ {
            $result = $sum
        }
        when /^ :i u/ {
            $result = $user
        }
        when /^ :i s/ {
            $result = $sys
        }
	default { 
            die "FATAL: Unknown \$typ option '$_'" 
        }
    }
    $result

} # read-sys-time

#------------------------------------------------------------------------------
# Subroutine: seconds-to-hms
# Purpose : Return input time in seconds (without or with a trailing 's') or convert time in seconds to hms or h:m:s format.
# Params  : Time in seconds.
# Returns : Time in in seconds (without or with a trailing 's') or hms format, e.g, '3h02m02.65s', or h:m:s format, e.g., '3:02:02.65'.
sub seconds-to-hms($Time,
                   :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                   --> Str) is export(:seconds-to-hms) {

    my $time = $Time;

    my UInt $sec-per-min = 60;
    my UInt $min-per-hr  = 60;
    my UInt $sec-per-hr  = $sec-per-min * $min-per-hr;

    my UInt $hr  = ($time/$sec-per-hr).UInt;
    my $sec = $time - ($sec-per-hr * $hr);
    my UInt $min = ($sec/$sec-per-min).UInt;

    $sec = $sec - ($sec-per-min * $min);

    my $ts;
    if !$fmt {
        $ts = $time;
    }
    elsif $fmt ~~ /^ :i s/ {
        $ts = sprintf "%.2fs", $sec;
    }
    elsif $fmt ~~ / ':'/ {
        $ts = sprintf "%d:%02d:%05.2f", $hr, $min, $sec;
    }
    elsif $fmt ~~ /^ :i h/ {
        $ts = sprintf "%dh%02dm%05.2fs", $hr, $min, $sec;
    }

    $ts;

} # seconds-to-hms

#------------------------------------------------------------------------------
# Subroutine: time-command
# Purpose : Collect the process times for a system or user command (using the GNU 'time' command).
# Params : The command as a string, and four named parameters that describe which type of time values to return and in what format. Note that special characters are not recognized by the 'run' routine, so results may not be as expected if they are part of the command.
# Returns : A string consisting in one or all of real (wall clock), user, and system times (in one of four formats), or a list as in the original API.
sub time-command(Str:D $cmd,
                 :$typ where { !$typ.defined || $typ ~~ &typ }, # see token 'typ' definition
                 :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, # see token 'fmt' definition
                 :$rtn where { !$rtn.defined || $rtn ~~ &rtn }, # see token 'rtn' definition
                 :$dir,                                         # run command in dir 'dir'
                 :$debug,
                ) is export {
    # runs the input cmd using the system 'run' function and returns
    # the process times according to the input params

    # look for the time program in several places:
    my $TCMD;
    my $TE = 'GNU_TIME';
    my @t = <
        /bin/time
        /usr/bin/time
        /usr/local/bin/time
    >;
    if %*ENV{$TE}:exists && %*ENV{$TE}.IO.f {
        $TCMD = %*ENV{$TE};
    }
    else {
        for @t -> $t {
            if $t.IO.f {
                $TCMD = $t;
                last;
            }
        }
    }
    if !$TCMD.defined {
        die "FATAL: The 'time' command was not found on this host.";
    }

    # the '-p' option (or --portability) gives the standard POSIX output display:
    #   >$ time locate lib
    #   >real 1.35
    #   >user 0.42
    #   >sys 0.28

    $TCMD ~= " -p"; # OSX doesn't recognize option:  --portability

    my $CMD = "$TCMD $cmd";
    my ($exitcode, $stderr, $stdout);
    if $dir.defined {
	($exitcode, $stderr, $stdout) = run-command $CMD, :$dir;
    }
    else {
	($exitcode, $stderr, $stdout) = run-command $CMD;
    }

    if $exitcode.defined and $exitcode {
        die qq:to/HERE/;
            FATAL: The '$CMD' command returned a non-zero exitcode: $exitcode
                   stderr: $stderr
                   stdout: $stdout
            HERE
    }

    my $result = $stderr // ''; # the time command puts all process time output to stderr

    # check for a default format if none are specified here
    my ($dtyp, $dfmt, $drtn) = decode-gnu-time-format;
    my $Typ = $dtyp.defined ?? $dtyp !! $typ;
    my $Fmt = $dfmt.defined ?? $dfmt !! $fmt;
    my $Rtn = $drtn.defined ?? $drtn !! $rtn;

    # default is to return same as running "time -p cmd 1> /tmp/stdout"
    if not ($Typ.defined or $Fmt.defined or $Rtn.defined) {
        note "DEBUG: returning with default time format" if $debug;
        return $result;
    }

    # more details are handled in a subroutine
    read-sys-time $result, :typ($Typ), :fmt($Fmt), :rtn($Rtn), :$debug;

} # time-command


#  my ($dtyp, $dfmt, $drtn) = decode-gnu-time-format;
sub decode-gnu-time-format is export(:decode-time-format) {
    my $s = %*ENV{$gte} // Nil;
    my ($typ, $fmt, $rtn);
    return ($typ, $fmt, $rtn) unless $s.defined and $s;

    my $debug = 0;

    # remove all whitepace, semicolons, and commas
    say "\$s original: |$s|" if $debug;
    $s ~~ s:g/\s//;
    $s ~~ s:g/';'//;
    $s ~~ s:g/','//;
    say "\$s cleaned: |$s|" if $debug;

    if $s ~~ /:i 'typ(' (\S+) ')' / {
        my $val = ~$0;
        if $val ~~ /^r/ {
            $typ = 'r';
        }
        elsif $val ~~ /'+'/ {
            $typ = '+';
        }
        elsif $val ~~ /^u/ {
            $typ = 'u';
        }
        elsif $val ~~ /^s/ {
            $typ = 's';
        }
    }

    if $s ~~ /:i 'fmt(' (\S+) ')' / {
        my $val = ~$0;
        if $val ~~ /^s/ {
            $fmt = 's';
        }
        elsif $val ~~ /':'/ {
            $fmt = ':';
        }
        elsif $val ~~ /^h/ {
            $fmt = 'h';
        }
    }

    if $s ~~ /:i 'rtn(' (\S+) ')' / {
        my $val = ~$0;
        if $val ~~ /^l/ {
            $rtn = 'l';
        }
        elsif $val ~~ /^h/ {
            $rtn = 'h';
        }
    }
    $typ, $fmt, $rtn;

} # sub decode-gnu-time-format

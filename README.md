[![Actions Status](https://github.com/tbrowder/GNU-Time/workflows/test/badge.svg)](https://github.com/tbrowder/GNU-Time/actions)

NAME
====

**GNU::Time** - Provides an easy interface for the GNU `time` command on Linux and OSX hosts (usually installed as '/bin/time' or '/usr/bin/time') to time user commands.

NOTE: This module replaces the time-related routines in module **Proc::More** (which is now deprecated).

Of course one can use the Raku `now` routine before and after a command to achieve calculating the total wall clock time, but sometimes one may be interested in the actual process time without including the times of other processes on the host computer.

SYNOPSIS
========

```raku
use GNU::Time;
# get the proces times (in seconds) for a system command:
say time-command "locate lib"; # OUTPUT: «real 0.23␤user 0.22␤sys 0.01␤»
```

DESCRIPTION
===========

Raku module **GNU::Time** provides the `time-command` subroutine for easy access to the GNU `time` command on Linux and OSX hosts. The default is to return the same output format as running the following command at the host's command line interface:

```bash
$ /bin/time -p locate lib 1>/tmp/stdout
real 0.23
user 0.22
sys 0.01
```

Note the `TIME` environment variable format, if defined, is ignored.

INSTALLATION
============



First, ensure the GNU `time` command is installed on your host. If required, you may install it from source.

Getting the `time` command
--------------------------

On Debian and other Linux hosts the `time` command may not be installed by default, but it is available in package `time`. It can also be built from source available at the *Free Software Foundation*'s git site. Clone the source repository:

```raku
    $ git clone https://git.savannah.gnu.org/git/time.git
```

The build and install instructions are in the repository along with the source code. Details of the GNU `time` command may be seen by executing `man 1 time` at the command line.

Unfortunately, there is no equivalent command available for Windows unless you install Cygwin or an equivalent system. (The author has seen Windows command scripts posted on Stack Overflow but has not tried any himself.)

sub time-command
----------------

Purpose : Collect the process times for a system or user command (using the GNU `time` command). Runs the input command using the Raku `run` routine and returns the process times shown below (all times are in seconds):

  * `real` - real (wall clock) time

  * `user` - user time

  * `system` - system time

### Signature:

```raku
sub time-command(Str:D $cmd,
                 :$typ where { !$typ.defined || $typ ~~ &typ },
                 :$fmt where { !$fmt.defined || $fmt ~~ &fmt },
                 :$rtn where { !$rtn.defined || $rtn ~~ &rtn },
		 :$dir,
                ) is export {...}
```

### Parameters:

  * `$cmd` - The command as a string. Note special characters are not recognized by Raku's `run` routine, so results may not be as expected if they are part of the command.

  * `:$typ` - Type of time values to return (see token `typ` definition)

  * `:$fmt` - Desired format of returned time values (see token `fmt` definition)

  * `:$rth` - Desired return type (see token `rtn` definition)

  * `:$dir` - Directory in which to execute the command

### The `typ`, `fmt`, and `rtn` tokens:

Note the user should either use the single-character form of the token or at least two characters of the multi-character form to ensure proper disambiguation of the desired token. For example, the character 'u' alone is taken to be the 'user' type while 'u+' is the "sum" type. In all cases, the canonical name of each token is the single-character shown for each token.

```raku
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
    h|hash|  
$ }
```

### Returns one of:

  * A string consisting of real (wall clock), user, **and** system times [default]

  * A string consisting in one of real (wall clock), user, **or** system times

  * A list consisting of real (wall clock), user, and system times (in that order)

  * A hash of all of real (wall clock), user, and system times keyed by 'real', 'user', and 'system'

All returned time values are in the default or the selected format.

### `GNU_Time_Format` environment variable

The user may set the desired default type, format, and return type by setting the **GNU_Time_Format** environment variable as in the following example

```sh
export GNU_Time_Format='typ(u)' # returns the user time in seconds
```

where 'typ()', 'fmt()', and 'rtn()' are "tokens" with values within their trailing parentheses. The values within parentheses are expected to be the appropriate ones for the signature tokens. Multiple tokens may be separated by semicolons, whitespace, or commas. Whitespace is ignored. Missing values and tokens are ignored as are malformed or unrecognized tokens or values.

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT and LICENSE
=====================

Copyright © 2021 Tom Browder

This library is free software; you may redistribute or modify it under the Artistic License 2.0.


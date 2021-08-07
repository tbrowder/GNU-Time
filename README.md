[![Actions Status](https://github.com/tbrowder/GNU-Time/workflows/test/badge.svg)](https://github.com/tbrowder/GNU-Time/actions)

NAME
====

**GNU::Time** - Provides an easy interface for the GNU `time` command on Linux and OSX hosts.

NOTE: This module replaces the time-related routines in module **Proc::More** (which is now deprecated).

SYNOPSIS
========

```raku
use GNU::Time;
say time-command "locate lib"; # OUTPUT 0.260
```

DESCRIPTION
===========

**GNU::Time** provides the `time-command` subroutine for easy access to the GNU `time` command on Linux and OSX hosts.

sub time-command
----------------

Purpose : Collect the process times for a system or user command (using the GNU `time` command). Runs the input command using the system `run` function and returns the process times shown below.

```raku
sub time-command(Str:D $cmd,
                 :$typ where { $typ ~~ &typ } = 'u',            
                 :$fmt where { !$fmt.defined || $fmt ~~ &fmt }, 
		 :$dir,
                 Bool :$list = False,
                ) is export {...}
```

### Parameters:

  * `$cmd` - The command as a string. Note special characters are not recognized by Raku's `run` routine, so results may not be as expected if they are part of the command.

  * `:$typ` - Type of time values to return (see token `typ` definition)

  * `:$fmt` - Desired format of returned time values (see token `fmt` definition)

  * `:$dir` - Directory in which to execute the command

  * `:$list` - Return the time values as a list

### The `typ` and `fmt` tokens:

```raku
my token typ { ^ :i        
    # the desired time(s) to return:
    a|all|   # show all times in desired format
    r|real|  # show real (wall clock) time
    u|user|  # show the user time [default]
    s|sys    # show the system time
$ }

my token fmt { ^ :i        
    # the desired format for the time(s) 
                # [default: raw seconds]
    s|seconds|  # time in seconds with an appended 
                #   's': "30.42s"
    h|hms|      # time in hms format: "0h00m30.42s"
    ':'|'h:m:s' # time in h:m:s format: "0:00:30.42"
$ }
```

### Returns:

A string consisting in one or all of real (wall clock), user, and system times (in one of four formats), or a list as in the original API.

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT and LICENSE
=====================

Copyright © 2021 Tom Browder

This library is free software; you may redistribute or modify it under the Artistic License 2.0.


#!/bin/sh
# dt_contents.sh: Output the names of all [non-group] records in a DT database.
#                 Options allow specifing the top-level group for the listing
#                 and enable verbose output.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 [-v] [-d] [-p path]
	Content Options
	    -p path  List contents of 'path' instead of root.
	    -r       Recurse into subdirectories
	    -v       Verbose output"
START_PATH="root of current database"
DETAIL=""
RECURSE="false"
DL="\"|\""	# delimiter

while getopts rv\?p: opt
do
	case "$opt"
	in
		# NOTE: 'size' property fails sometimes so we use word count
		v) DETAIL="$DL & (id of c) as text & $DL & kind of c & $DL & \
			   date of c & $DL & (word count of c) as text & \
			   $DL & comment of c &";;
		r) RECURSE="true";;
		p) START_PATH="(get record at \"$OPTARG\" in current \
		               database)" ;;
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

# Applescript for contents
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on do_group(g, recurse_group)
    set out to ""
    
    tell application "DEVONthink Pro"
        set g_children to children of g
    end tell

    repeat with c in g_children

        tell application "DEVONthink Pro"
            if type of c is group then
                set recurse to recurse_group
             else 
                set recurse to false
                set out to out & location of c & name of c & $DETAIL my nl
             end if
        end tell

        if recurse then
             set out to out & do_group(c, recurse_group)
    end if

    end repeat

    return out
end

tell application "DEVONthink Pro"
    copy $START_PATH to r
end tell

try
    -- verify that path exists: nested try is an attempt at 'if defined(r)'
    get r
    try
	set result to do_group(r, $RECURSE)
    on error msg
        set result to "ERROR: " & msg & nl
    end try
on error
    set result to "ERROR: Invalid path" & nl
end try


EOF`

echo -ne $VAR




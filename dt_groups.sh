#!/bin/sh
# dt_groups.sh : List groups in the current Devonthink Database.
#                Options allow recursive listing and specifying the top-level 
#                group for the listing.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 [-r] [path] "
RECURSE="false"

while getopts r\? opt
do
	case "$opt"
	in
		r) RECURSE="true" ;;
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

shift $((OPTIND - 1))

if [ -n "$1" ]
then
	START_PATH="get record at \"$1\""
else
	START_PATH="get root of current database"
fi

# Applescript for group list
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on get_groups(rec, recurse)
    set out to ""

	tell application "DEVONthink Pro"
		set loc to location of rec
    	set grp_list to every child of rec whose type is group
	end tell
	
	repeat with g in grp_list
		set out to out & loc & name of rec & "/" & name of g & my nl
		if recurse then
			set out to out & get_groups(g, recurse)
		end	if
	end
	
	return out
end

set recurse to $RECURSE

tell application "DEVONthink Pro"
	set rec to ($START_PATH)
end tell

set result to get_groups(rec, recurse)
EOF`

echo -ne $VAR




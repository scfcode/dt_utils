#!/bin/sh
# dt_get_id.sh : Get the id of a record in the DT database based on its path.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 path"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND)) -gt $# ]
then
	echo "ERROR: path argument is mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
REC_PATH=$1

# Input validation
if [ -z "$REC_PATH" ]
then
	echo "ERROR: path cannot be empty"
	exit 3
fi


# Applescript for get_id
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on get_record(path_str)
     
    tell application "DEVONthink Pro"
        set r to get record at path_str
		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & path_str & ": " & msg & my nl
		end try
		
		return id of r as text & my nl
    end tell
end

set result to get_record("$REC_PATH")

EOF`

echo -ne $VAR

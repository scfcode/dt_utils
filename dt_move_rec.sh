#!/bin/sh
# dt_move_rec.sh : Move a record in the DT database to a different group.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 record_id group_path"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND + 1)) -gt $# ]
then
	echo "ERROR: record_id and group_path arguments are mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
REC_ID=$1
GRP_PATH=$2

# Input validation
echo $REC_ID | grep '[^0-9]'
if [ $? -eq 0 ]
then
	echo "ERROR: record_id must be an integer"
	exit 3
fi

if [ -z "$GRP_PATH" ]
then
	echo "ERROR: group_path must be non-NULL"
	exit 4
fi

# Applescript for move
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on move_record(r_id, grp_path)
     
    tell application "DEVONthink Pro"
        set r to get record with r_id
		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & r_id as text & ": " & msg & my nl
		end try
		
		-- get new group
		set g to get record at grp_path in current database
		try
	    	get g
		on error msg
	    	return "ERROR: Unable to find " & grp_path & ": " & msg & my nl
		end try
		
		-- move record
		try
			move record r to g
		on error msg
	    	return "ERROR: Unable to move to " & grp_path & ": " & msg & my nl
		end try
    end tell

	return ""
end

set result to move_record($REC_ID, "$GRP_PATH")

EOF`

echo -ne $VAR




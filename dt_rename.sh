#!/bin/sh
# dt_rename.sh : Rename a record in the DT database.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 record_id new_name"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND + 1)) -gt $# ]
then
	echo "ERROR: record_id and new_name arguments are mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
REC_ID=$1
NEW_NAME=$2

# Input validation
echo $REC_ID | grep '[^0-9]'
if [ $? -eq 0 ]
then
	echo "ERROR: record_id must be an integer"
	exit 3
fi

if [ -z "$NEW_NAME" ]
then
	echo "ERROR: name must be non-NULL"
	exit 4
fi

# Applescript for export
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on rename_record(r_id, new_name)
     
    tell application "DEVONthink Pro"
        set r to get record with r_id
		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & r_id as text & ": " & msg & my nl
		end try
		
		-- rename record
		try
			set name of r to new_name
		on error msg
	    	return "ERROR: Unable to rename to " & new_name & ": " & msg & my nl
		end try
    end tell

	return ""
end

set result to rename_record($REC_ID, "$NEW_NAME")

EOF`

echo -ne $VAR



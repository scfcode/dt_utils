#!/bin/sh
# dt_sync_rec.sh : Synchronize a Link record in the DT database with its on-disk files.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 record_id"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND)) -gt $# ]
then
	echo "ERROR: record_id argument is mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
REC_ID=$1

# Input validation
echo $REC_ID | grep '[^0-9]'
if [ $? -eq 0 ]
then
	echo "ERROR: record_id must be an integer"
	exit 3
fi


# Applescript for sync
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on sync_record(r_id)
     
    tell application "DEVONthink Pro"
        set r to get record with r_id
		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & r_id as text & ": " & msg & my nl
		end try
		
		if path of r is "" then return "ERROR: Record " & r_id as text & " is not linked to any files." & my nl
		
		-- synchronize record
		try
			synchronize record r
		on error msg
	    	return "ERROR: Unable to synchronize: " & msg & my nl
		end try
    end tell

	return ""
end

set result to sync_record($REC_ID)

EOF`

echo -ne $VAR

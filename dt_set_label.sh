#!/bin/sh
# dt_set_label.sh : Set the label of a DT record.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 record_id label_id"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND + 1)) -gt $# ]
then
	echo "ERROR: record_id and label_id arguments are mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
REC_ID=$1
LBL_ID=$2

# Input validation
echo $REC_ID | grep '[^0-9]'
if [ $? -eq 0 ]
then
	echo "ERROR: record_id must be an integer"
	exit 3
fi

echo $LBL_ID | grep '[^0-9]'
if [ $? -eq 0 ]
then
	echo "ERROR: label_id must be an integer"
	exit 3
fi

if [ $LBL_ID -lt 0 ] || [ $LBL_ID -gt 7 ]
then
	echo "ERROR: label_id must be in the range 0-7"
	exit 3
fi

# Applescript for setting label
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on label_record(r_id, new_label)
     
    tell application "DEVONthink Pro"
        set r to get record with r_id
		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & r_id as text & ": " & msg & my nl
		end try
		
		-- set label
		try
			set label of r to new_label
		on error msg
	    	return "ERROR: Unable to set label " & new_label as text & ": " & msg & my nl
		end try
    end tell

	return ""
end

set result to label_record($REC_ID, $LBL_ID)
EOF`

echo -ne $VAR

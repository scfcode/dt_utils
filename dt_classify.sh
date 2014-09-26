#!/bin/sh
# dt_classify : Output classification proposals for a DT record based on 
#              its database ID.
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


# Applescript for classify
VAR=`osascript <<EOF

on record_info(r_id)
    set nl to "\\\\\\\\n"	-- newline (escaped)

    tell application "DEVONthink Pro"
        set r to get record with r_id

		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & e_id as text & ": " & msg & nl
		end try
		
		-- output classification groups
		set out to ""
		repeat with g in classify record r
			set out to out & location of g & name of g & nl
		end repeat

    end tell

	return out
end

set result to record_info($REC_ID)

EOF`

echo -ne $VAR




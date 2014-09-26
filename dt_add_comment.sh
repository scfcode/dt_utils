#!/bin/sh
# dt_add_comment.sh : Append a comment to a DT record.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)

HELP_STR="Usage: $0 record_id comment_str"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND + 1)) -gt $# ]
then
	echo "ERROR: record_id and comment_str arguments are mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
REC_ID=$1
REC_CMT=$2

# Input validation
echo $REC_ID | grep '[^0-9]'
if [ $? -eq 0 ]
then
	echo "ERROR: record_id must be an integer"
	exit 3
fi

if [ -z "$REC_CMT" ]
then
	echo "ERROR: comment must be non-NULL"
	exit 4
fi

# Applescript for setting comment
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on comment_record(r_id, new_cmt)
     
    tell application "DEVONthink Pro"
        set r to get record with r_id
		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & r_id as text & ": " & msg & my nl
		end try
		
		-- get comment
		set cmt_str to comment of r
		if length of cmt_str > 0 then set cmt_str to cmt_str & return

		-- append comment
		set comment of r to cmt_str & new_cmt
    end tell

	return ""
end

set result to comment_record($REC_ID, "$REC_CMT")
EOF`

echo -ne $VAR




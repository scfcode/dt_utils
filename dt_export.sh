#!/bin/sh
# dt_export.sh : Export a record from a DT database based on its ID.
#                Path to which the record will be exported is required.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 record_id output_path"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND + 1)) -gt $# ]
then
	echo "ERROR: record_id and output_path arguments are mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
REC_ID=$1
REC_PATH=$2

# Input validation
echo $REC_ID | grep '[^0-9]'
if [ $? -eq 0 ]
then
	echo "ERROR: record_id must be an integer"
	exit 3
fi

if [ -z "$REC_PATH" ]
then
	echo "ERROR: output_path must be non-NULL"
	exit 4
fi

# Applescript for export
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on export_record(r_id, out_path)
     
    tell application "DEVONthink Pro"
        set r to get record with r_id
		-- check that record exists
        try
	    	get r
		on error msg
	    	return "ERROR: Unable to find " & r_id as text & ": " & msg & my nl
		end try
		
		-- export record
		try
	    	export record r to out_path
		on error msg
	    	return "ERROR: Unable to write " & out_path & ": " & msg & my nl
		end try
    end tell

end

set result to export_record($REC_ID, "$REC_PATH")

EOF`

echo -ne $VAR




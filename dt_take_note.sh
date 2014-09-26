#!/bin/sh
# dt_take_note : Take plain text on STDIN and import it into DT at
#                the specified location.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 [path]"

while getopts \? opt
do
	case "$opt"
	in
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

# Get Params
shift $((OPTIND - 1))
DEST_PATH="$1"

if [ -z "$DEST_PATH" ]
then
	DEST_PATH="(get root of current database)"
else
	DEST_PATH="(get record at \"${DEST_PATH}\")"
fi

# Read in data from STDIN
DATA=""
while read LINE
do
	DATA="${DATA}${LINE}\n"
done
echo -e $DATA | pbcopy


# Applescript for record info
VAR=`osascript <<EOF

on take_note()
    set nl to "\\\\\\\\n"	-- newline (escaped)

    tell application "DEVONthink Pro"
        set g to $DEST_PATH
		-- check that dest group exists
        try
	    	get g
		on error msg
	    	return "ERROR: Unable to find " & location of g & name of g & ": " & msg & nl
		end try
		
		-- take note
		set r to paste clipboard to g 
		set out to location of r & name of r & "|" & (id of r) as text & my  nl
    end tell

	return out
end

set result to take_note()

EOF`

echo -ne $VAR




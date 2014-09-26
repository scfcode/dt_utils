#!/bin/sh
# dt_create_group.sh : Create a new group in the DT database.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 [-x] group_path
	Create options:
	  -c		Check group (state is True)
	  -o	    Outline group (show state)
	  -s path	Attach script at POSIX path ('Smart group')
	  -x		Exclude from classification"
EXCLUDE_STR=""
SMART_GROUP=""
SHOW_STATE=""
CHECKED_STATE="set state of r to false"


while getopts cox\?s: opt
do
	case "$opt"
	in
		c) CHECKED_STATE="set state of r to true";;
		o) SHOW_STATE="set state visibility of r to true";;
		s) SMART_GROUP="set attached script of r to \"$OPTARG\"";;
		x) EXCLUDE_STR="set exclude from classification of r to true";;
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
GRP_PATH=$1

# Input validation
if [ -z "$GRP_PATH" ]
then
	echo "ERROR: path must be non-NULL"
	exit 4
fi

# state cannot be set unless it is also shown
if [ -z "$SHOW_STATE" ]
then
	CHECKED_STATE=""
fi

# Command to fill smart group
FILL_SMART_GROUP=""
if [ -n "$SMART_GROUP" ]
then
	FILL_SMART_GROUP="
	try
		tell application \"DEVONthink Pro\"
			copy attached script of r to script_path
		end tell
	
		set rec_script to load script alias (POSIX file script_path)
		tell rec_script to triggered(r)
	on error msg
		tell application \"DEVONthink Pro\"
			log message \"dt_create_group.sh\" info \"Unable to trigger script \" & script_path & \": \" & msg
		end tell
	end try
	"
fi

# Applescript for create
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on create_group(path_str)
     
    tell application "DEVONthink Pro"
		try
			set r to create location path_str
			$EXCLUDE_STR
			$SHOW_STATE
			$CHECKED_STATE
		on error msg
	    	return "ERROR: Unable to create " & path_str & ": " & msg & my nl
		end try
		try
			$SMART_GROUP
		on error msg
	    	return "ERROR: Unable to attach script to new group " & id of r as text & ": " & msg & my nl
		end try

		set out to (id of r) as text & my  nl
    end tell
	
	$FILL_SMART_GROUP

	return out
end

set result to create_group("$GRP_PATH")

EOF`

echo -ne $VAR




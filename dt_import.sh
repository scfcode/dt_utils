#!/bin/sh
# dt_import.sh : Import a file into a DT database. Options allow the
#                type of file and the destination group to be specified.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 -[A|C|F|I|L|M|P|Q|R|S|T|X] [-g group] [path]
	Import File Type Options:
	  -A		All/Any
	  -C		Chat
	  -F		Form
	  -I		Image
	  -L		Location
	  -M		Markup
	  -P		PDF
	  -Q		Quicktime
	  -R		Rich Text
	  -S		Script
	  -T		Simple
	  -X		Sheet
	Import Location options:
	  -g path	Group to import into"
	
IMPORT_TYPE="all"
DEST_PATH="(get root of current database)"

while getopts ACFILMPQRSTX\?g: opt
do
	case "$opt"
	in
		# Import File Flags
		A) IMPORT_TYPE="all" ;;
		C) IMPORT_TYPE="chat" ;;
		F) IMPORT_TYPE="form" ;;
		I) IMPORT_TYPE="image" ;;
		L) IMPORT_TYPE="location" ;;
		M) IMPORT_TYPE="markup" ;;
		P) IMPORT_TYPE="PDF" ;;
		Q) IMPORT_TYPE="quicktime" ;;
		R) IMPORT_TYPE="rich" ;;
		S) IMPORT_TYPE="script" ;;
		T) IMPORT_TYPE="simple" ;;
		X) IMPORT_TYPE="sheet" ;;
		# Group to import into
		g) DEST_PATH="(get record at \"$OPTARG\")";;
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
IMPORT_PATH=$1

# Input validation
if [ -z "$IMPORT_PATH" ]
then
	echo "ERROR: path cannot be empty"
	exit 3
fi

# Applescript for import
VAR=`osascript <<EOF

on import_file(in_path)
	set nl to "\\\\\\\\n"	-- newline (escaped)
     
    tell application "DEVONthink Pro"
        set g to $DEST_PATH

		-- check that dest group exists
        try
	    	get g
		on error msg
	    	return "ERROR: Unable to find " & location of g & name of g & ": " & msg & nl
		end try
		
		try
	     	set r to import in_path to g type $IMPORT_TYPE
		on error msg
	    	return "ERROR: Unable to import " & in_path & ": " & msg & nl
		end try
		set out to location of r & name of r & "|" & (id of r) as text &   nl
    end tell

	return out
end

set result to import_file("$IMPORT_PATH")

EOF`

echo -ne $VAR




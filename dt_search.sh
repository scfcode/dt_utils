#!/bin/sh
# dt_search.sh : Search DT database for a string. Options allow the top-level
#                group for the search, and provide access to the standard
#                DT search parameters (comparison, operator, within).
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 -[E|F|I] -[A|P|W|Z] -[a|c|p|t|u] [-g path] [-d path] search_string
	Comparison Options
	   -E       Exact (default)
	   -F       Fuzzy
	   -I       Case-insensitive
	Operator Options
	   -A       Any word
	   -P       Phrase
	   -W       Wildcards
	   -Z       All words (default)
	Within Options
	   -a       All (default)
	   -c       Comments
	   -p       Paths
	   -t       Titles
	   -u       URLs
	Other Options
	   -g path  Search within group at 'path'
	   -r path  Replicate results to group at 'path'"

SEARCH_CMP="exact"
SEARCH_OP="all words"
SEARCH_IN="all"
SEARCH_GROUP=""
REP_GROUP=""

while getopts EFIZAPWacptu\?g:r: opt
do
	case "$opt"
	in
		# Comparison Flags
		E) ;;
		F) SEARCH_CMP="fuzzy" ;;
		I) SEARCH_CMP="no case" ;;
		# Operator Flags
		Z) ;;
		A) SEARCH_OP="any word" ;;
		P) SEARCH_OP="phrase" ;;
		W) SEARCH_OP="wildcards" ;;
		# Within Flags
		a) ;;
		c) SEARCH_IN="comments" ;;
		p) SEARCH_IN="paths" ;;
		t) SEARCH_IN="titles" ;;
		u) SEARCH_IN="URLs" ;;
		# Group to search in
		g) SEARCH_GROUP="in (get record at \"$OPTARG\")" ;;
		r) REP_GROUP="replicate to (get record at \"$OPTARG\")";;
		\?) echo "$HELP_STR";  exit 1;;
	esac
done

if [ $((OPTIND)) -gt $# ]
then
	echo "ERROR: search_string argument is mandatory"
	exit 2
fi

# Get Params
shift $((OPTIND - 1))
SEARCH_STR=$1

# Input validation
if [ -z "$SEARCH_STR" ]
then
	echo "ERROR: search_str cannot be empty"
	exit 3
fi

# Output format
DL="\"|\""
DETAILS="location of r & name of r & $DL & (id of r) as text & $DL & \
         kind of r & $DL & date of r & $DL & (word count of r) as text & \
         $DL & comment of r"

# Applescript for search
VAR=`osascript <<EOF
set nl to "\\\\\\\\n"	-- newline (escaped)

on find_records(s)
    set out to ""
     
    tell application "DEVONthink Pro"
	search s comparison $SEARCH_CMP $SEARCH_GROUP operator $SEARCH_OP $REP_GROUP within $SEARCH_IN 
	
	repeat with r in result
	    set out to out & $DETAILS & my nl
	end repeat
    end tell

end

set result to find_records("$SEARCH_STR")

EOF`

echo -ne $VAR




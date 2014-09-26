#!/bin/sh
# dt_record_info : Output details of a DT record base on its database ID.
# Copyright (c) 2006, Eric Fedel. Released under the BSD License.
# (http://home.earthlink.net/~efedel/code/devon_think/index.html)


HELP_STR="Usage: $0 -[acdilpstuwxDFILST] record_id
	Record Metadata Options:
	   -a		Attributes of record (Locking, Exclude, State, Score, etc)
	   -c		Comment of record
	   -d		Date (create and modify) of record
	   -i		ID of record
	   -l		Location of record
	   -n		Name and DT Path of record
	   -t		Type of record
	   -w		Wiki aliases
	   -L		Label of record
	Record data options:
	   -p		Path associated with record
	   -s		Size and Word Count of record
	   -u		URL associated with record
	   -x		Attached script (Smart Group)
	   -D		Table Data (Sheet record)
	   -F		Proposed filename
	   -I		Image attributes
	   -S		Source of record (markup)
	   -T		Text data of record"
	
ALL="1"	# default to all options

while getopts acdilnpstuwxDFILST\? opt
do
	case "$opt"
	in
		a) ALL="" OPT_a="1";;
		c) ALL="" OPT_c="1";;
		d) ALL="" OPT_d="1";;
		i) ALL="" OPT_i="1";;
		l) ALL="" OPT_l="1";;
		n) ALL="" OPT_n="1";;
		p) ALL="" OPT_p="1";;
		s) ALL="" OPT_s="1";;
		t) ALL="" OPT_t="1";;
		u) ALL="" OPT_u="1";;
		w) ALL="" OPT_w="1";;
		x) ALL="" OPT_x="1";;
		D) ALL="" OPT_D="1";;
		F) ALL="" OPT_F="1";;
		I) ALL="" OPT_I="1";;
		L) ALL="" OPT_L="1";;
		S) ALL="" OPT_S="1";;
		T) ALL="" OPT_T="1";;

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


# Build Applescript for Output String
OUT_STR=""

[ -n "$ALL" ] || [ -n "$OPT_i" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"ID: \" & id of r as text & nl"

[ -n "$ALL" ] || [ -n "$OPT_t" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Type: \" & kind of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_n" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Name: \" & name of r & nl
	set out_str to out_str & \"DT Path: \" & location of r & name of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_l" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Location: \" & location of r & nl"
	
[ -n "$ALL" ] || [ -n "$OPT_d" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Create Date: \" & creation date of r & nl
	set out_str to out_str & \"Modify Date: \" & modification date of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_a" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Indexed: \" & indexed of r as text & nl
	set out_str to out_str & \"Excluded from Classification: \" & (exclude from classification of r) as text & nl
	set out_str to out_str & \"Locking: \" & locking of r as text & nl
	set out_str to out_str & \"State Visibility: \" & state visibility of r as text & nl
	set out_str to out_str & \"State: \" & state of r as text & nl
	try
		set score_str to score of r as text
	on error
		set score_str to \"N/A\"
	end try
	set out_str to out_str & \"Score: \" & score_str & nl
	set out_str to out_str & \"Duplicates: \" & number of duplicates of r as text & nl
	set out_str to out_str & \"Replicants: \" & number of replicants of r as text & nl
	set out_str to out_str & \"Children: \" & number of children of r as text & nl"

[ -n "$ALL" ] || [ -n "$OPT_w" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Wiki Aliases: \" & aliases of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_I" ] && OUT_STR="${OUT_STR}
	if type of r is picture then
		set out_str to out_str & \"Image Attributes: Height: \" & height of r as text & \" Width: \" & width of r as text and \" DPI: \" & dpi of r as text & nl
	else
		set out_str to out_str & \"Image Attributes: None\" & nl
	end if"
	
[ -n "$ALL" ] || [ -n "$OPT_u" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"URL: \" & url of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_p" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Path: \" & path of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_F" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Proposed Filename: \" & filename of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_x" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Script: \" & attached script of r & nl"

[ -n "$ALL" ] || [ -n "$OPT_L" ] && OUT_STR="${OUT_STR}
	set out_str to out_str & \"Label: \" & label of r as text & nl"

[ -n "$ALL" ] || [ -n "$OPT_c" ] && OUT_STR="${OUT_STR}
	-- need to remove emedded returns 
	copy comment of r to the_cmt
	set AppleScript's text item delimiters to return
	set cmt_list to text items of the_cmt
	set AppleScript's text item delimiters to \"\"
	set cmt_str to \"\"
	repeat with cmt in cmt_list
		set cmt_str to cmt_str & cmt & nl
	end repeat
	set out_str to out_str & \"Comment: \" & cmt_str & nl"

[ -n "$ALL" ] || [ -n "$OPT_s" ] && OUT_STR="${OUT_STR}
	try
		set sz to size of r -- doesn't seem to work
	on error
		set sz to \"?\"
	end try 
	set out_str to out_str & \"Size: \" & sz as text & nl
	set out_str to out_str & \"Word Count: \" & (word count of r) as text & nl"

[ -n "$ALL" ] || [ -n "$OPT_S" ] && OUT_STR="${OUT_STR}
	set src_str to source of r
	if length of src_str > 0 then
		set out_str to out_str & \"Source: \" & nl & src_str & nl
	else
		set out_str to out_str & \"Source: \" & nl
	end if"

[ -n "$ALL" ] || [ -n "$OPT_T" ] && OUT_STR="${OUT_STR}
	set txt_str to plain text of r
	if length of txt_str > 0 then
		set out_str to out_str & \"Text: \" & nl & txt_str & nl
	else
		set out_str to out_str & \"Text: \" & nl
	end if"

[ -n "$ALL" ] || [ -n "$OPT_D" ] && OUT_STR="${OUT_STR}
	if type of r is sheet then
		set tbl_str to \"\"
		if number of children of r > 0 then set tbl_str to nl
		
		-- handle table header
		set col_list to columns of r
		if length of col_list > 0 then set tbl_str to tbl_str & \"# \"
		repeat with col in col_list
			set tbl_str to tbl_str & col as text & tb
		end repeat
		set tbl_str to tbl_str & nl
		
		-- handle rows of data
		repeat with row in children of r
			set cell_list to cells of row
			repeat with c in cell_list
				set tbl_str to tbl_str & c as text & tb
			end repeat
			set tbl_str to tbl_str & nl
		end repeat
		set out_str to out_str & \"Table Data: \" & tbl_str & nl
	else
		set out_str to out_str & \"Table Data: None\" & nl
	end if"

 
# Applescript for record info
VAR=`osascript <<EOF

on record_info(r_id)
    set nl to "\\\\\\\\n"	-- newline (escaped)
    set tb to "\\\\\\\\t"	-- tab (escaped)

    tell application "DEVONthink Pro"
        set r to get record with r_id

		-- check that record exists
        try
			get r
		on error msg
			return "ERROR: Unable to find " & r_id as text & ": " & msg & nl
		end try
		
		-- output record info
		set out_str to ""
		$OUT_STR

    end tell

	return out_str
end

set result to record_info($REC_ID)

EOF`

echo -ne $VAR




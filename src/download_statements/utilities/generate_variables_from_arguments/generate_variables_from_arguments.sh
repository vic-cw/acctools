#! /bin/bash

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME <default_cut_off_date> <end_date_generator> <start_date_generator> <files_base_name> \
[-h] [-d output_directory] [-f filename] [-c cut_off_date] [end_date]
	       $SCRIPT_NAME <default_cut_off_date> <end_date_generator> <start_date_generator> <files_base_name> \
[-h] [-d output_directory] [-f filename] [-c cut_off_date] <start_date> <end_date>

	Outputs variables describing actions to be taken to download bank statements, one on each line, 
	in the following order :
		- Directory in which to create subfolder to store bank statements
		- Statements base name (full name without extension)
		- Start date of statements
		- End date of statements

	If no extra argument is provided, end date is calculated by running <end_date_generator>.

	If only one extra argument is provided, it is assumed to be the end date, and the start date 
	is computed by running <start_date_generator> with end date as parameter.

	If -d option is provided with <output_directory>, files are saved in a new folder in <output_directory>. 
	Otherwise, files are saved in a new folder in the current working directory, whose name is set to the files base name (see below).

	If -f option is provided with <filename>, files are named with <filename>.<extension>.
	Otherwise, files base name is the concatenation of <files_base_name> and "<start_date> to <end_date>".

	Dates must be formatted as yyyy-mm-dd.

EOF
)

shopt -s xpg_echo

# Check enough parameters were provided

if [ $# -lt 4 ]; then
	echo "$USAGE_MESSAGE"
	exit 1
fi

# Read base parameters

DEFAULT_CUT_OFF_DATE="$1"
END_DATE_GENERATOR="$2"
START_DATE_GENERATOR="$3"
FILES_BASE_NAME="$4"

shift 4

# Check base parameters

INTEGER_REGEX="^([0-9]|[0-9][0-9])$"
if [[ ! "$DEFAULT_CUT_OFF_DATE" =~ $INTEGER_REGEX ]] || [ $DEFAULT_CUT_OFF_DATE -gt 31 ] || \
	[ $DEFAULT_CUT_OFF_DATE -eq 0 ]; then
	echo "$USAGE_MESSAGE"
	exit 1
fi

# Read options

OUTPUT_DIRECTORY_CUSTOMIZE=false
BASENAME_CUSTOMIZE=false
CUT_OFF_DATE_CUSTOMIZE=false

ARGUMENTS_TO_SHIFT=0

while getopts ":hd:f:c:" opt; do
	case "$opt" in
		h)
			echo "$USAGE_MESSAGE"
			exit 0
			;;
		d)
			OUTPUT_DIRECTORY_CUSTOMIZE=true
			OUTPUT_DIRECTORY_PROVIDED="$OPTARG"
			ARGUMENTS_TO_SHIFT=$(( ARGUMENTS_TO_SHIFT + 2 ))
			;;
		f)
			BASENAME_CUSTOMIZE=true
			BASENAME_PROVIDED="$OPTARG"
			ARGUMENTS_TO_SHIFT=$(( ARGUMENTS_TO_SHIFT + 2 ))
			;;
		c)
			CUT_OFF_DATE_CUSTOMIZE=true
			CUT_OFF_DATE_PROVIDED="$OPTARG"
			ARGUMENTS_TO_SHIFT=$(( ARGUMENTS_TO_SHIFT + 2 ))
			;;
			
		\?)
			echo "Error: invalid option \"$OPTARG\" provided"
			exit 1
			;;
		:)
			echo "Error: no argument provided to \"-$OPTARG\" option"
			exit 1;
			;;
	esac
done

shift $ARGUMENTS_TO_SHIFT

# Interpret cut-off date

CUT_OFF_DATE="$DEFAULT_CUT_OFF_DATE"

if $CUT_OFF_DATE_CUSTOMIZE; then
	CUT_OFF_DATE="$CUT_OFF_DATE_PROVIDED"
	if [[ ! "$CUT_OFF_DATE" =~ $INTEGER_REGEX ]] || [ $CUT_OFF_DATE -gt 31 ] || [ $CUT_OFF_DATE -eq 0 ]; then
		echo "Error: Invalid cut-off date provided to $SCRIPT_NAME : $CUT_OFF_DATE"
		exit 1
	fi
fi
unset CUT_OFF_DATE_PROVIDED
	


# Check dates are correct

_DIR_=$(dirname "${BASH_SOURCE[0]}")
DATE_UTILITIES_DIR="$_DIR_/../date_utilities"

if [ $# -lt 1 ]; then
	END_DATE=$($END_DATE_GENERATOR "$CUT_OFF_DATE")
	START_DATE=$($START_DATE_GENERATOR "$END_DATE")

elif [ $# -lt 2 ]; then
	END_DATE="$1"
	if ! "$DATE_UTILITIES_DIR/date_is_valid/date_is_valid.sh" "$END_DATE" ; then
		echo "Error: Wrong end date provided : $END_DATE"
		exit 1
	fi
	START_DATE=$($START_DATE_GENERATOR "$END_DATE")

else
	END_DATE="$2"
	START_DATE="$1"
	if ! "$DATE_UTILITIES_DIR/date_is_valid/date_is_valid.sh" "$END_DATE" ; then
		echo "Error: Wrong end date provided : $END_DATE"
		exit 1
	fi

	if ! "$DATE_UTILITIES_DIR/date_is_valid/date_is_valid.sh" "$START_DATE" ; then
		echo "Error: Wrong start date provided : $START_DATE"
		exit 1
	fi

	GNU_DATE=$(date --version >/dev/null 2>&1 && echo true || echo false)

	END_DATE_TO_INT=$($GNU_DATE && date -d "$END_DATE" "+%Y%m%d" \
		  						|| date -ujf"%Y-%m-%d" "$END_DATE" "+%Y%m%d")
	START_DATE_TO_INT=$($GNU_DATE && date -d "$START_DATE" "+%Y%m%d" \
		  						|| date -ujf"%Y-%m-%d" "$START_DATE" "+%Y%m%d")

	if [ $START_DATE_TO_INT -gt $END_DATE_TO_INT ]; then
		echo "Error: Start date is later than end date"
		exit 1
	fi
fi


# Interpret other options

if $OUTPUT_DIRECTORY_CUSTOMIZE; then
	OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY_PROVIDED"
else
	OUTPUT_DIRECTORY="$PWD"
fi
unset OUTPUT_DIRECTORY_PROVIDED


if $BASENAME_CUSTOMIZE; then
	BASENAME="$BASENAME_PROVIDED"
else
	BASENAME="$FILES_BASE_NAME$START_DATE to $END_DATE"
fi
unset BASENAME_PROVIDED


# Make sure output directory ends with a "/"

OUTPUT_DIRECTORY=$(echo $OUTPUT_DIRECTORY | sed 's,/$,,')


# Output results

echo "$OUTPUT_DIRECTORY"
echo "$BASENAME"
echo "$START_DATE"
echo "$END_DATE"

exit 0

#! /bin/bash

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF
    Usage : $SCRIPT_NAME [-h] <cut_off_date>

    If -h option is provided, displays this help message.

    Otherwise computes latest cut-off date for a statement from current date,
    and prints it to the standard output. Latest cut-off date is computed as the latest day
    with a day number equal to <cut_off_date> and strictly prior to current date.

    <cut_off_date> must be a valid number between 1 and 31. Otherwise, nothing gets printed and false gets returned.
    Returns true if everything went well.

EOF
)

shopt -s xpg_echo

# Check for call of help

while getopts "h" opt; do
	case "$opt" in 
		h)
			echo "$USAGE_MESSAGE"
			exit 0
			;;
		\?)
			echo "$USAGE_MESSAGE"
			exit 1
			;;
	esac
done

# Read arguments

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE"
	exit 1
fi

CUT_OFF_DATE="$1"


# Call script with today's date 

_DIR_=$(dirname "${BASH_SOURCE[0]}")
TODAY=$(date "+%Y-%m-%d")

"$_DIR_/../generate_end_date_from_date/generate_end_date_from_date.sh" \
    "$CUT_OFF_DATE" \
    "$TODAY"

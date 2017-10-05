#! /bin/bash

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h] <end_date>

	If -h option is provided, displays this help message.

	Otherwise, parses <end_date> and prints the computed corresponding start date to standard output.

	Start date is computed as the day following the day with the same day number one month before,
	except in case end date is the last day of the month, in which case start date is computed as the first day of the month.

	Examples :
		2015-03-14 => 2015-02-15
		2015-03-31 => 2015-03-01
		2015-03-30 => 2015-03-01
		2015-03-27 => 2015-02-28

	<end_date> must be of the format yyyy-mm-dd. If not, false is returned and nothing is outputed.


EOF
)

shopt -s xpg_echo

# Read options

while getopts "h" opt; do
	case "$opt" in
		h)
			echo "$USAGE_MESSAGE" >&2
			exit 0
			;;
		\?)
			echo "$USAGE_MESSAGE" >&2
			exit 1
			;;
	esac
done


# Read arguments

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

END_DATE="$1"


# Check end date is of the correct format

_DIR_=$(dirname "${BASH_SOURCE[0]}")
DATE_UTILITIES_DIR="$_DIR_/../date_utilities"

if ! "$DATE_UTILITIES_DIR/date_is_valid/date_is_valid.sh" "$END_DATE" ; then
	echo "Error: wrong format for end date provided '$END_DATE'.\nPlease provide an end date in yyyy-mm-dd format" >&2
	exit 1
fi


# If date is the last day of the month, return the first day of the month

GNU_DATE=$(date --version >/dev/null 2>&1 && echo true || echo false)

if $GNU_DATE ; then
	DAY=$(date -d "$END_DATE" "+%d")
	LAST_DAY_OF_THE_MONTH=$(date -d "$END_DATE - $(( DAY - 1 )) day + 1 month - 1 day" "+%d")

	if [ $DAY = $LAST_DAY_OF_THE_MONTH ]; then
		date -d "$END_DATE - $(( DAY - 1 )) day" "+%Y-%m-%d"
		exit 0
	fi
else
	LAST_DAY_OF_THE_MONTH=$(date -uj -v+1m -v1d -v-1d -f "%Y-%m-%d" "$END_DATE" "+%Y-%m-%d")
	if [ "$END_DATE" = "$LAST_DAY_OF_THE_MONTH" ]; then
		date -uj -v1d -f "%Y-%m-%d" "$END_DATE" "+%Y-%m-%d"
		exit 0
	fi
fi

# Otherwise, print the day after the day with the same day number on the previous month

if $GNU_DATE ; then
	PREVIOUS_MONTH_LAST_DAY=$(date -d "$END_DATE - $DAY day" "+%d")

	if [ $DAY -ge $PREVIOUS_MONTH_LAST_DAY ]; then
		date -d "$END_DATE - $(( DAY - 1 )) day" "+%Y-%m-%d"
	else
		date -d "$END_DATE - 1 month + 1 day" "+%Y-%m-%d"
	fi
else
	date -uj -v-1m -v+1d -f "%Y-%m-%d" "$END_DATE" "+%Y-%m-%d"
fi


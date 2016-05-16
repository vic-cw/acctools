#! /bin/sh


USAGE_MESSAGE=$(cat <<"EOF"

	Usage: generate_end_date_from_date.sh [-h] <cut_off_date> <date>

	If -h option is provided, displays this help message.

	Otherwise, parses <date>, computes latest cut-off date for a statement from this date,
	and prints it to the standard output. Latest cut-off date is computed as the latest day
	with a day number equal to <cut_off_date> and strictly prior to <date>.

	<date> must be of the format yyyy-mm-dd and <cut_off_date> must be a valid number between 1 and 31.
    Otherwise, nothing gets printed and false gets returned.
	Returns true if everything went well.

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

if [ $# -lt 2 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

CUT_OFF_DATE="$1"
DATE="$2"


# Check arguments are correct

INTEGER_REGEX="^([0-9]|[0-9][0-9])$"

if [[ ! "$CUT_OFF_DATE" =~ $INTEGER_REGEX ]] || [ $CUT_OFF_DATE -gt 31 ] || [ $CUT_OFF_DATE -eq 0 ]; then
	echo "Error: wrong cut-off date '$CUT_OFF_DATE'.\nPlease provide cut-off date as an integer between 1 and 31." >&2
	echo >&2
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

_DIR_=$(dirname "${BASH_SOURCE[0]}")
DATE_UTILITIES_DIR="$_DIR_/../date_utilities"

if ! "$DATE_UTILITIES_DIR/date_is_valid/date_is_valid.sh" "$DATE" ; then
	echo "Error: wrong date '$DATE'.\nPlease provide a reference date in yyyy-mm-dd format." >&2
	echo >&2
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi


# Compute end date

GNU_DATE=$(date --version >/dev/null 2>&1 && echo true || echo false)

DAY=$($GNU_DATE && date -d "$DATE" "+%d" 2>/dev/null \
		        || date -uj -f "%Y-%m-%d" "$DATE" "+%d" 2>/dev/null)

if [ $DAY -gt $CUT_OFF_DATE ]; then
	$GNU_DATE && date -d "$DATE -$(( DAY - CUT_OFF_DATE ))  day" "+%Y-%m-%d" 2>/dev/null \
			|| date -uj -v${CUT_OFF_DATE}d -f "%Y-%m-%d" "$DATE" "+%Y-%m-%d" 2>/dev/null
else
	if $GNU_DATE ; then
		PREVIOUS_MONTH_LAST_DAY=$(date -d "$DATE - $DAY day" "+%d" 2>/dev/null)
		if [ $PREVIOUS_MONTH_LAST_DAY -lt $CUT_OFF_DATE ]; then
			date -d "$DATE - $DAY day" "+%Y-%m-%d" 2>/dev/null
		else
			date -d "$DATE - 1 month + $(( CUT_OFF_DATE - DAY )) day" "+%Y-%m-%d" 2>/dev/null
		fi
	else
		date -uj -v-1m -v${CUT_OFF_DATE}d -f "%Y-%m-%d" "$DATE" "+%Y-%m-%d" 2>/dev/null \
		|| date -uj -v1d -v-1d -f "%Y-%m-%d" "$DATE" "+%Y-%m-%d" 2>/dev/null
	fi
fi
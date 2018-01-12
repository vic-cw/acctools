#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <csv_file>

        Format <csv_file> into a csv file containing
        only list of transactions, remove everything else,
        convert dates to yyyy-mm-dd format, and print result 
        to standard output.

        Accept only files generated from BNP website.

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME bank_statement.xls > reformatted_bank_statement.csv


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

# Check for call of help

while getopts "h" opt; do
	case $opt in
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


# Read argument

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

FILE="$1"

_DIR_=$(dirname "${BASH_SOURCE[0]}")

cat "$1" | \
"$_DIR_/utilities/convert_csv/convert_csv_from_semicolon_to_comma.sh" | \
"$_DIR_/trim_boursorama_statement.sh" | \
"$_DIR_/utilities/convert_first_date/convert_first_date_from_european_to_universal/convert_first_date_from_european_to_universal.sh" | \
"$_DIR_/utilities/convert_first_date/convert_first_date_from_european_to_universal/convert_first_date_from_european_to_universal.sh"

if [ "${PIPESTATUS[0]}" = "0" ] && [ "${PIPESTATUS[1]}" = "0" ] && [ "${PIPESTATUS[2]}" = "0" ] \
	&& [ "${PIPESTATUS[3]}" = "0" ] && [ "${PIPESTATUS[4]}" = "0" ]; then
	exit 0
else
	exit 1
fi
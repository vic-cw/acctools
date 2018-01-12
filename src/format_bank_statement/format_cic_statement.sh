#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Format csv file <input_file> to make it ready for use in accounting
        software such as Wave accounting, and print result to standard output.

        Keep only transaction list from the file, remove everything else.

        Accepts only csv files generated by CIC.

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME downloaded_file.csv >reformatted_file.csv


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


# Proceed

_DIR_=$(dirname "${BASH_SOURCE[0]}")

"$_DIR_/"trim_cic_statement.sh "$FILE" | \
"$_DIR_/utilities/convert_first_date/convert_first_date_from_european_to_universal/convert_first_date_from_european_to_universal.sh" | \
"$_DIR_/utilities/convert_first_date/convert_first_date_from_european_to_universal/convert_first_date_from_european_to_universal.sh"

exit $?
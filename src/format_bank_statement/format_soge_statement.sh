#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Format csv file <input_file> to make it ready for use in accounting
        software such as Wave accounting, and print result to standard output.

        Perform 2 tasks :
           - keep only transaction list from the file, remove everything else
           - convert from semicolon-delimited csv file to comma-delimited

        Accepts only csv files generated by Société Générale.

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

"$_DIR_/"trim_soge_statement.sh "$FILE" | "$_DIR_/"convert_csv_from_semicolon_to_comma.sh

if [  ! "${PIPESTATUS[0]} ${PIPESTATUS[1]}" = "0 0" ] ; then
	exit 1
fi

exit 0
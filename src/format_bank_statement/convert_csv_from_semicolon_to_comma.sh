#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h]

        Reads a csv file from standard input, converts it from
        semicolon delimited to comma delimited, and prints the
        result to standard output.

Exit code:
        0   if all goes well
        1   otherwise

Options:
        -h  Display this help message

Example:
        cat \$CSV_FILE | $SCRIPT_NAME > converted_file.csv


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


# Convert

INPUT=`cat /dev/stdin`

_DIR_=$(dirname "${BASH_SOURCE[0]}")

PATH="$_DIR_/../utilities/phantomjs:$PATH" \
phantomjs "$_DIR_/convert_csv_from_semicolon_to_comma/phantomjs_convert_csv_from_semicolon_to_comma.js" "$INPUT"

EXIT_CODE="$?"

exit $EXIT_CODE

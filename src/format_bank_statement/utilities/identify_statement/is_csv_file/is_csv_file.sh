#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Tests whether <input_file> seems to be a csv file:
          - whether its extension is csv
          - whether it is a text file

Options:
        -h  Display this help message

Exit code:
        0   if answer is yes
        1   otherwise

EXAMPLE:
        if $SCRIPT_NAME downloaded_file.csv; then ...


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


# Check if file name finishes with .csv

CSV_REGEX=".+\.csv$"

if ! [[ "$FILE" =~ $CSV_REGEX ]]; then
	exit 1
fi


# Check that file is text, not binary

TEXT_REGEX="(.+text$|.+text, with CRLF, LF line terminators$|.+text, with CRLF line terminators$)"

if ! [[ $(file "$FILE") =~ $TEXT_REGEX ]]; then
	exit 1
fi

exit 0
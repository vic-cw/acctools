#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] [separator = /]

        Read file from standard input, replace first occurrence of
        a date in dd<...>mm<...>yyyy format to yyyy-mm-dd format, and 
        print result to standard output.

        Separator can be anything except backslash (\\).

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME bank_statement.csv > converted_bank_statement.csv


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

SEPARATOR="/"

if [ $# -gt 0 ]; then
	SEPARATOR="$1"
fi

S=$SEPARATOR

if [ "x$S" = "x\\" ]; then
	echo "Error : Wrong separator provided." >&2
	echo "$USAGE_MESSAGE" >&2
	exit 1;
fi

if [ "x$S" = "x/" ]; then
	SED_FORMULA='s_\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9][0-9][0-9][0-9]\)_\3-\2-\1_'
else
	SED_FORMULA='s/\([0-3][0-9]\)'"$S"'\([0-1][0-9]\)'"$S"'\([0-9][0-9][0-9][0-9]\)/\3-\2-\1/'
fi

sed "$SED_FORMULA"

exit $?
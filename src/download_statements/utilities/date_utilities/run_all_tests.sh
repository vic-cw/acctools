#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h]

        Run all tests in date_utilities directory and sub-directories,
        which are registered in this script.

Exit code:
        0   if all tests exit with code 0
        1   otherwise

Options:
        -h  Display this help message



Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

# Check for call of help

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


# Set up

ALL_GOOD=true
_DIR_=$(dirname ${BASH_SOURCE[0]})


# Run tests

"$_DIR_/date_is_valid/test.sh" "$_DIR_/date_is_valid/date_is_valid.sh" || \
    ALL_GOOD=false

# Announce results

echo

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

echo
if $ALL_GOOD ; then
	printf $green
	echo "All date_utilities tests passed successfully" $end_color
	exit 0
else
	printf $red
	echo "FAILURE" $end_color
	echo
	echo "Some date_utilities tests failed"
	echo
	exit 1
fi

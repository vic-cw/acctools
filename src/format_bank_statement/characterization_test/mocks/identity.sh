#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME -e <input_file>

        Prints content of <input_file> to standard output.

        This script is intended to be a mockup, to test format_bank_statement's characterization 
        tests, by providing it instead of a real script.

        -e option only exists to mimick options provided to a format_bank_statement script. 
        It doesn't change anything but is compulsory.

Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

while getopts "he" opt; do
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

if [ $# -lt 2 ] || [ ! "$1" = "-e" ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi			

cat "$2"